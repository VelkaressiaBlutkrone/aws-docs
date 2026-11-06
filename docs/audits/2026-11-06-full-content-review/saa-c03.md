# SAA-C03 콘텐츠 전수 검토 (2026-11-06)

대상: `flutter_app/assets/content/saa/` — 학습문서 **24편**(1,077,156 바이트) · 문항 **360개**(24 Task × 15, **360/360 `verified:true` 라이브**)
검토자: Fable 세션(SAA-C03 담당). 수정·커밋·테스트 실행 없음(보고서 1파일만 작성).

---

## 0. 검토 계획

실행 **전에** 세운 계획이고, 실행하며 달라진 점은 각 항목 끝에 `→ 실제` 로 덧붙였다.

### 0-1. 왜 이 순서인가

SAA는 외부 검수가 두 차례 들어와 수백 건이 이미 수정된 트랙이다. 그래서 **중복 보고를 피하는 것이 1순위 설계 제약**이었고, 다음 세 가지를 먼저 정했다.

1. **「이미 닫힌 것」을 기계로 확정한다.** 가드 테스트 25개 파일(`saa_*.dart`, 5,555줄 + 갭 배치 18개)이 사실상 2차 검수의 정본이다(`docs/saa-review/`에 SAA 2차 검수 보고 **전문은 저장돼 있지 않다** — 메모리 `review-report-canonical-record` 가 적은 「전사에만 남는다」 상태가 SAA에 그대로 해당한다). 따라서 가드가 **문항 id를 한 번이라도 언급하는지**로 「검수 거침/안 거침」을 가른다.
2. **미검수 문항을 깊게 본다.** 얕게 360개를 훑는 것보다, 2차 검수가 손대지 않은 문항을 공식 문서와 1:1로 맞추는 쪽이 새 결함을 찾는다.
3. **md는 「문항 가드가 보지 않는 영역」만 노린다.** 문항 가드는 `.md` 를 보지 않는다(레포가 #285·#288에서 비싸게 배운 교훈). 그래서 md는 전수 통독이 아니라 **가드가 구조적으로 못 보는 자리**(출처 URL, 자가 점검 블록, 전파 가드 금지 문구의 md 생존)를 겨냥한다.

### 0-2. 단계와 측정 명령

| 단계 | 무엇을 | 측정 명령 / 방법 |
|---|---|---|
| A | 가드 커버리지 산출 | `saa_*.dart` 전수에서 `saa-tN-M-qK` 정규식 추출 → 360개와 차집합 |
| B | 기계 스캔(표기·메모·일반화·쏠림·중복) | 문항 JSON 24개 전수 파싱 후 필드별 집계 + **타 자격증 5종 대조군** |
| C | 렌더 경로 실측 | `lib/` 에서 `stem`·`options`·`explanation`·`wrongExplanations` 를 그리는 위젯을 전수 추적 |
| D | 출처 URL 전수 실측 | `curl -sL -o /dev/null -w "%{http_code} r=%{num_redirects} -> %{url_effective}"` + **대조군 5종** + 실패 시 `aws___read_documentation` 2차 판정 |
| E | 미검수 문항 정독 → 공식 대조 | Task별 덤프 → 의심 항목을 `aws___read_documentation` / `aws___search_documentation` 으로 원문 확인 |
| F | 범위(D축) 대조 | 공식 가이드 「범위 내/외 AWS 서비스」 **실측 전수**를 정답 보기 서비스명과 기계 대조 |
| G | md 겨냥 검사 | ① 전파 가드 금지 문구 56개 × md 24편 전수 ② 자가 점검 블록 대 본문 모순 ③ md 전용 출처 |

### 0-3. 측정 규율에서 미리 고정한 것

- **`-L` 없는 `curl` 은 `num_redirects` 가 항상 0**이다. 전부 `-sL`.
- 판정 신호는 호스트·경우마다 다르므로 **대조군을 먼저 잰다**(§1에 결과).
- **`curl` 의 `r=1` 만으로 「문서 소멸」을 선언하지 않는다.** AWS 문서 리더로 두 번째 방법을 쓴다 — 「문서가 사라졌다」와 「사람이 브라우저로 열 수 없다」는 다른 판정이다.
- **「공식에 없다」를 말하기 전에** 추출 둘 · 대조군 문구 · 동의어 · 표·목록 구조 · md의 영문 인용문 자체로 검색, 다섯 가지를 한다.
- **개수를 믿지 않는다.** 「N곳에 있다」는 전부 `grep` 전수로 다시 센다.
- **공식이 갈리면 더 구체적인 전용 페이지를 정본**으로 삼고, 양쪽 URL을 함께 적는다.

### 0-4. 계획과 달라진 점 (→ 실제)

- **D단계가 한 번 무효가 됐다.** `xargs` 로 파일에서 URL을 먹여 488개를 병렬 측정했더니 **488건 전부 `000 r=0`**(연결 실패)이었는데, 같은 URL을 명령문에 리터럴로 쓰면 `200` 이 나왔다. 이 환경의 네트워크 허용이 **명령 문자열에 URL이 literal로 있을 때만** 열린다. → 488개를 8배치로 쪼개 **명령문에 직접 써서** 다시 쟀다. 전부 `000` 이라는 결과를 그대로 믿었다면 「전 출처가 죽었다」는 거짓 보고를 냈을 것이다.
- **E단계의 「의심」이 자주 틀렸다.** 내 사전 지식 기반 의심 7건이 공식 실측에서 **전부 기각**됐다(§5-2). 그래서 중반부터 「의심 → 즉시 공식 원문 확인」을 예외 없이 적용했다.
- **F단계를 계획보다 강화했다.** 레포 `exam_guides/SAA-C03.json` 에는 **서비스 목록 자체가 없다**(키가 `code·slug·overview·domains·sourceUrl` 뿐). 그래서 공식 가이드의 「범위 내/외」 페이지를 직접 읽어 목록을 만들고 대조했다.

---

## 1. 집계

| 항목 | 수 |
|---|---|
| 읽은 학습문서 | 24편 전수(1,077,156 바이트) — 통독 4편 + 겨냥 검사 24편 |
| 파싱한 문항 | **360개 전수**(필드별 기계 스캔) |
| 정독한 문항(전문) | **178개** — 가드가 한 번도 언급하지 않은 「미검수」 전량 + 의심 11개 |
| 가드 커버리지 | 가드가 언급하는 고유 문항 **182/360**, 미언급 **178/360** |
| 측정한 URL | **487 / 488** (고유 URL 488 중 1건은 `#policies_session` 앵커 변형이라 본체로 대체) |
| 대조한 공식 페이지(원문 열람) | **27** (AWS 문서 리더 24 + 내장 브라우저 3) |
| 실행한 대조군 측정 | **7** (URL 5 + 「없다」 판정 대조군 2) |
| 발견 | **P1 4건 · P2 8건 · P3 9건** |
| 기존 가드와 충돌하는 제안 | **1건**(그마저도 「가드가 틀렸다」 쪽) |

### URL 측정 대조군 (전부 과제 명세대로 나왔다 → 측정 유효)

```
200 r=1 https://docs.aws.amazon.com/sagemaker/latest/dg/zz-bogus-control.html -> .../sagemaker/latest/dg/
404 r=0 https://aws.amazon.com/what-is/zz-bogus-control/
200 r=0 https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html   ← 살아 있는 페이지
404 r=0 https://docs.aws.amazon.com/zz-bogus-guide/latest/dg/x.html                      ← 가이드 접두사 자체 없음
403 r=0 https://repost.aws/knowledge-center/                                             ← 봇 차단
```

AWS 문서 리더 대조군도 함께 쟀다 — 틀린 슬러그 `sagemaker/latest/dg/zz-bogus-control.html` 는 `redirected_url: .../whatis.html` 을 **보고한다**. 즉 리더의 `redirected_url` 은 신뢰할 수 있는 신호다(이 사실이 §3-2 판정의 근거다).

### URL 실측 결과 분포 (487건)

| 신호 | 건수 | 판정 |
|---|---|---|
| `200 r=0` | 474 | 정상 |
| `200 r=1` (docs.aws.amazon.com) | 9 | §3-1(4건 은퇴) · §3-2(5건 백서) |
| `200 r=1` (aws.amazon.com) | 2 | §3-4 경미 |
| `200 r=1` (단축 URL) | 1 | §3-4 경미 |
| `403` (repost.aws) | 3 | **봇 차단 — 전부 살아 있음**(§5-1에서 브라우저로 확인) |
| `404` | 0 | — |

---

## 2. P1 — 라이브 사실 오류 (즉시 수정 대상)

> 네 건 모두 **라이브**다. 1·2는 학습문서, 3은 문항 해설, 4는 문항 표기다.
> ⚠️ **1·2는 둘 다 「자가 점검」 블록이다.** 과거 정정이 §본문·비교표에는 반영됐는데 같은 파일의 자가 점검 정답만 옛 서술을 그대로 들고 있다. 이것이 이번 검토에서 찾은 **반복 패턴**이고, 수정 PR에서는 24편 전체의 자가 점검 블록을 같은 눈으로 한 번 더 훑기를 권한다.

---

### P1-1. `saa-t4-2.md:481` — 공식이 하지 않은 권장을 「공식 문서도 ~ 권장합니다」로 적는다

**1) 위치**
`flutter_app/assets/content/saa/saa-t4-2.md:481` (🧪 자가 점검 **Q1 정답 보기** 블록 안)

**2) 현재 문구 (그대로 인용)**

> **Compute Savings Plans (3년, All Upfront)**입니다. 인스턴스 패밀리·리전·OS를 자유롭게 변경할 수 있으면서 최대 66%의 할인을 제공합니다. Standard RI는 인스턴스 유형 변경이 제한되어 유연성이 낮습니다. **AWS 공식 문서도 Reserved Instances보다 Savings Plans를 먼저 고려하도록 권장합니다.**

**3) 왜 틀렸는지**

세 겹으로 틀렸다.

- **공식에 그런 문장이 없다.** 이 주제의 정본 페이지(`sp-ris`)는 **절감률·유연성 비교 표**와 「Savings Plans는 용량을 예약하지 않는다」만 제시하고, 어느 쪽을 먼저 고려하라고 말하지 않는다.
- **같은 파일이 스스로 부정한다.** `saa-t4-2.md:102` 가 이미 경고 박스로 적는다 — *「"AWS가 Savings Plans를 먼저 고려하라고 명시한다"는 서술은 공식에서 확인되지 않습니다.」* 102줄과 481줄이 정면으로 모순이다.
- **파생 문항이 이미 정정돼 있다.** `saa-t4-2-q5` 해설: *「공식 비교 페이지는 Savings Plans와 RI 중 어느 쪽을 먼저 고려하라고 말하지 않습니다.」* 즉 **md만 옛 주장을 남긴 채 문항은 고쳐졌다** — 레포가 반복해서 경계해 온 전파 방향(md→문항)의 **역방향 잔존**이다.

왜 중요한가: 용량 확보가 요건이면 SP는 답이 아니다(Zonal RI·ODCR). 「SP 먼저」라는 우선순위 단정은 그 갈림길을 지운다.

**4) 공식 URL + 실측 근거**

- 정본: <https://docs.aws.amazon.com/savingsplans/latest/userguide/sp-ris.html> (`200 r=0`)
- **전문 확인**(AWS 문서 리더, 2,581자 전체 — 잘림 없음). 페이지에 있는 것은 ① 4열 비교 표(Compute SP 66% / EC2 Instance SP 72% / Convertible RI 66% / Standard RI 72%) ② `Savings Plans doesn't provide capacity reservations, but you can allocate On-Demand Capacity Reservation (ODCR) for your needs and your Savings Plans will apply.` ③ `Savings Plans doesn't apply to spot usage or usage covered by RIs.` **우선순위를 말하는 문장은 0건.**
- **「없다」 규율 적용**: 대조군으로 같은 추출에서 `doesn't provide capacity reservations`(1건)·`Up to 66%`(2건)를 셌다 — **대조군이 잡히므로 추출은 작동했고**, `recommend`·`first`·`prefer`·`consider` 계열은 우선순위 맥락으로 0건이다.
- **탈출 경로 실측**: md 가드 `G-4.2-14`(`saa_t2_t4_facts_test.dart:523-534`)는 세 리터럴만 본다 —
  `'먼저 고려하라"고 명시'` / `'Savings Plans 우선 권장'` / `'AWS 공식 우선 권장'`.
  **481줄의 실제 문구 `먼저 고려하도록 권장` 은 셋 중 무엇과도 일치하지 않는다.**
  한편 `saa_question_propagation_test.dart:405` 는 **정확히 `'먼저 고려하도록 권장'`** 을 금지 문구로 등록해 두었는데, 그 가드는 **문항만** 본다. 그래서 같은 문자열이 문항에서는 막히고 md에서는 살아남았다.
  (기계 재현: 전파 가드의 금지 문구 56개를 md 24편 전수와 대조 → 유효 탈출 **1건**, 그것이 이 줄이다.)

**5) 제안 수정안**

481줄의 마지막 문장을 삭제하고 조건 서술로 바꾼다(102줄·q5와 같은 어조):

> ~~AWS 공식 문서도 Reserved Instances보다 Savings Plans를 먼저 고려하도록 권장합니다.~~
> → **공식 비교 페이지는 어느 쪽을 먼저 고르라고 말하지 않습니다. 패밀리·리전·서비스를 바꿀 유연성이 요건이면 Savings Plans, 특정 AZ의 용량 확보가 요건이면 Zonal RI 또는 ODCR입니다.**

**가드 보강(동봉 권장)**: `G-4.2-14` 에 `expect(t42.contains('먼저 고려하도록 권장'), isFalse);` 를 추가한다. ⚠️ 단 102줄의 경고문은 `먼저 고려하라고 명시` 를 **인용**하므로, 새 단정은 **102줄이 쓰지 않는 어미**(`도록 권장`)여야 한다 — 가드 파일 주석이 경고하는 「반박문 거짓양성」이 여기서 실제로 성립한다.

**기존 가드 충돌**: 없음(위 보강은 새 단정 추가).

---

### P1-2. `saa-t3-2.md:468` + `saa-t3-2-q4` 해설 — 「부팅 볼륨은 SSD만 가능」은 거짓이고 같은 파일이 반증한다

**1) 위치**

- `flutter_app/assets/content/saa/saa-t3-2.md:468` (🧪 자가 점검 **「흔한 오해」 2번**)
- `flutter_app/assets/content/saa/saa-t3-2.questions.json` — `saa-t3-2-q4` 의 `explanation`

**2) 현재 문구 (그대로 인용)**

md:468 —
> 2. **"st1이나 sc1을 부팅 볼륨으로 사용할 수 있다."** → HDD 볼륨(st1·sc1)은 부팅 볼륨으로 사용할 수 없습니다. **부팅 볼륨은 SSD(gp2·gp3·io1·io2)만 가능합니다.**

`saa-t3-2-q4` explanation —
> HDD 볼륨(st1·sc1)은 부팅 볼륨으로 사용할 수 없습니다. **부팅 볼륨은 SSD(gp2·gp3·io1·io2)만 가능합니다.** HDD는 OS 부팅 시 발생하는 랜덤 소규모 I/O 패턴에 대응하지 못해 부팅 볼륨에서 제외됩니다.

**3) 왜 틀렸는지**

핵심 답(「st1은 부팅 볼륨 불가」)은 맞지만, **그 이유로 붙인 일반화가 거짓**이다. 이전 세대 **Magnetic(`standard`) 볼륨은 부팅 볼륨으로 지원된다.** 즉 부팅 가능 집합은 「SSD 4종」이 아니라 「SSD 4종 + `standard`」이고, 부팅 불가인 것은 **HDD 신세대 2종(st1·sc1)** 이다.

그리고 **같은 파일이 이미 반증을 들고 있다** — `saa-t3-2.md:236`:

> | 루트 볼륨 제약 | `io1`·`io2`·`gp2`·`gp3`·**`standard`** 루트 볼륨은 **`st1`·`sc1` 으로 변경 불가**(분리된 상태여도) |

236줄은 `standard` 를 루트 볼륨 유형으로 세고 있는데 468줄은 그것을 배제한다. 같은 문서 안의 모순이다.

**4) 공식 URL + 실측 근거**

- <https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html> (`200 r=0`), 전문 5,818자 확인(잘림 없음)
- 「이전 세대 볼륨」 표 그대로:
  | | Magnetic |
  |---|---|
  | **Volume type** | `standard` |
  | **Boot volume** | **Supported** |
- 같은 페이지 HDD 표: `st1` / `sc1` → **Boot volume: Not supported**. SSD 표: gp3·gp2·io2 Block Express·io1 → **Boot volume: Supported**.
- ⚠️ **이 사실은 산문이 아니라 표의 행에 있다.** 「Magnetic은 부팅 가능」이라는 문장을 산문으로 찾으면 0건이다 — 표 구조를 보지 않으면 영원히 못 찾는 자리다(§5-5의 규율이 실제로 걸린 사례).
- ⚠️ `saa-t3-2.md` 는 **놀랄 만큼 현행이다**: gp3 최대 80,000 IOPS·2,000 MiB/s, io2 256,000은 Nitro 전용(그 외 32,000), Outposts 제한, SDK 문서의 `3,000–16,000` 과의 차이까지 적는다(147·181·186·191줄). 전수 대조에서 이 파일의 EBS 수치는 **전부 공식 표와 일치**했다. 즉 결함은 §3 표가 아니라 **자가 점검 블록 한 줄**이다.

**5) 제안 수정안**

md:468 과 `saa-t3-2-q4` 의 `explanation` 에서 같은 문장을 고친다.

> ~~부팅 볼륨은 SSD(gp2·gp3·io1·io2)만 가능합니다.~~
> → **부팅 볼륨으로 지원되는 것은 SSD 4종(gp2·gp3·io1·io2)과 이전 세대 Magnetic(`standard`)이고, 신세대 HDD인 st1·sc1만 지원되지 않습니다.**

(문항의 `correct` 인덱스 `1`·보기 본문은 바꿀 필요가 없다. 정답 보기는 「st1은 부팅 볼륨으로 사용할 수 없다 — HDD 볼륨(st1·sc1)은 부팅 볼륨 미지원이다」로 이미 정확하다.)

**기존 가드 충돌**: 없음. `saa-t3-2-q4` 를 언급하는 가드 0건, `부팅 볼륨은 SSD` 를 단정하는 가드 0건(`flutter_app/test/*.dart` 전수 grep).

---

### P1-3. `saa-t3-5-q1` 해설 — Multi-AZ를 「HA 전용」으로 단정해 DB 클러스터 배포에서 거짓이 된다

**1) 위치**
`flutter_app/assets/content/saa/saa-t3-5.questions.json` — `saa-t3-5-q1` 의 `explanation` (`verified:true`, `correct: 0`)

**2) 현재 문구 (그대로 인용)**

> **Multi-AZ는 고가용성 전용 기능입니다.** 다른 AZ에 동기 복제된 스탠바이를 유지하고, 주 인스턴스 장애 시 AWS가 자동으로 DNS 엔드포인트를 스탠바이로 전환합니다(약 1~2분). **스탠바이는 읽기에 사용되지 않으며 HA 전용입니다.**

**3) 왜 틀렸는지**

「RDS Multi-AZ」는 **배포 유형이 둘**이다. 스탠바이 1개짜리 **Multi-AZ DB 인스턴스 배포**에서는 스탠바이가 읽기를 처리하지 않지만, 스탠바이 2개짜리 **Multi-AZ DB 클러스터 배포**에서는 **리더 인스턴스가 읽기를 처리한다.** 「Multi-AZ는 고가용성 **전용**」·「HA 전용」은 후자에서 거짓이다.

이것은 **레포가 이미 세 번 고친 바로 그 결함 유형**이다(가드 주석 기준: 2차 검수 §C의 `saa-t3-5-q6`·`saa-t4-3-q7`, 우선순위 2 A조 3문항). `saa-t3-5-q1` 은 가드가 한 번도 언급하지 않은 미검수 문항이라 같은 정정이 닿지 않았다.

**문항 안에서도 어긋난다** — 같은 문항의 `wrongExplanations["1"]` 는 올바르게 한정한다:
> **기본 Multi-AZ 인스턴스 배포에서** 스탠바이는 읽기를 제공하지 않습니다.

**학습문서는 두 편 모두 옳다**(= 문항 단독 오류, md 선결 불필요):
- `saa-t3-5.md:118-119` — 「이 스탠바이 인스턴스는 **읽기에 사용 불가**입니다(고가용성 전용).」 **바로 다음 줄**에 「Multi-AZ DB 클러스터 배포는 스탠바이 2개를 두며, **리더 인스턴스가 읽기를 처리할 수 있고**…」
- `saa-t2-4.md:190` — 「여기서의 Multi-AZ는 … **DB 인스턴스 배포(single standby)** 기준입니다. 읽기 가능한 스탠바이 2개를 제공하는 **Multi-AZ DB 클러스터**는 별도 배포 옵션입니다.」

**4) 공식 URL + 실측 근거**

- <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html> (`200 r=0`), 전문 1,842자(잘림 없음) 첫 문단:
  > Multi-AZ deployments can have one standby or two standby DB instances. When the deployment has one standby DB instance, it's called a *Multi-AZ DB instance deployment*. A Multi-AZ DB instance deployment has one standby DB instance that provides failover support, but doesn't serve read traffic. When the deployment has two standby DB instances, it's called a *Multi-AZ DB cluster deployment*. **A Multi-AZ DB cluster deployment has standby DB instances that provide failover support and can also serve read traffic.**
- 문항이 단 출처는 `AmazonRDS/latest/UserGuide/Welcome.html`(소개 페이지)이고, 그 페이지는 배포 유형 둘을 가르지 않는다. **출처 적합성도 함께 약하다**(§4-9의 92건 집단에 속한다).

**5) 제안 수정안**

`explanation` 두 곳을 한정한다. `correct` 인덱스 `0`·보기 본문은 불변(정답 보기 「다른 가용 영역에 동기 복제된 스탠바이를 유지하며…」는 DB 인스턴스 배포를 정확히 기술한다).

> ~~Multi-AZ는 고가용성 전용 기능입니다.~~ → **지문의 Multi-AZ는 스탠바이 1개짜리 Multi-AZ DB 인스턴스 배포입니다.**
> ~~스탠바이는 읽기에 사용되지 않으며 HA 전용입니다.~~ → **이 배포의 스탠바이는 읽기를 처리하지 않고 장애 조치만 담당합니다. 스탠바이 2개를 두는 Multi-AZ DB 클러스터 배포는 별도 옵션이고, 그쪽 리더 인스턴스는 읽기도 처리합니다.**

**출처 보강(권장)**: `Concepts.MultiAZ.html` 을 추가한다.

**기존 가드 충돌**: 없음(`saa-t3-5-q1` 을 언급하는 가드 0건, `HA 전용`·`고가용성 전용` 을 단정하는 가드 0건).
⚠️ 단 `saa-t3-5.md:118` 의 「(고가용성 전용)」은 **바로 다음 줄이 클러스터를 명시하므로 정당한 서술**이다 — 가드를 md 전역 금지로 걸면 그 줄이 걸린다. 가드는 **문항 `saa-t3-5-q1` 에 한정**해야 한다.

---

### P1-4. [G/렌더] 문항 JSON의 `**굵게**` 20개소가 학습자에게 **별표 그대로** 보인다

**1) 위치**
문항 JSON **8파일 · 9문항 · 20개소**(전부 `explanation` 또는 `wrongExplanations`):

| 파일 | 개소 | 문항 |
|---|---|---|
| `saa-t1-1.questions.json` | 1 | `saa-t1-1-q8` |
| `saa-t1-2.questions.json` | 2 | `saa-t1-2-q5` |
| `saa-t2-4.questions.json` | 4 | `saa-t2-4-q7` |
| `saa-t3-5.questions.json` | 3 | `saa-t3-5-q3` |
| `saa-t3-6.questions.json` | 2 | `saa-t3-6-q15` |
| `saa-t3-7.questions.json` | 3 | `saa-t3-7-q5` |
| `saa-t4-1.questions.json` | 2 | `saa-t4-1-q10` |
| `saa-t4-5.questions.json` | 3 | `saa-t4-5-q13` |

**2) 현재 문구 (예시 그대로 인용)**

- `saa-t1-1-q8` explanation: `… 세션 정책은 역할 정책과의 **교집합**으로 …`
- `saa-t4-1-q10` explanation: `… **활성화한 프로토콜별로 시간당** … **삭제할 때까지** …`
- `saa-t2-4-q7` explanation: `… **재시도 폭풍(retry storm)** … **지수 백오프** … **지터** … **높음(High)**`

**3) 왜 틀렸는지 — 렌더 경로를 전수로 확인했다**

문항 본문을 그리는 위젯이 **네 경로 모두 마크다운 파서를 거치지 않는 평문 `Text`** 다:

| 경로 | 코드 | 렌더 |
|---|---|---|
| 퀴즈 지문 | `lib/pages/quiz_page.dart:212` | `Text(q.stem, …)` |
| 보기 | `lib/content/quiz_widgets.dart:69` (`OptionTile`) | `Text(text, …)` |
| 퀴즈 해설·왜 아닌가 | `lib/pages/quiz_page.dart:227,237` → `ExplainBox` → `quiz_widgets.dart:110` | `Text(text, …)` |
| 시험 결과·복습 | `lib/content/quiz_widgets.dart:393,399` | `Text(q.explanation, …)` / `Text(q.wrongExplanations[...], …)` |

즉 `**교집합**` 은 **별표를 포함한 글자 그대로** 화면에 뜬다. (학습문서 `.md` 는 파서를 타므로 `**굵게**` 가 정상 렌더된다 — 그래서 저작자가 md 감각으로 문항에 넣었을 가능성이 높다.)

**4) 공식 URL + 실측 근거**

이 항목은 외부 근거가 아니라 **레포 내부 대조군**이 근거다.

```
$ grep -o '\*\*[^*]\+\*\*' assets/content/{clf,soa,dea,mla,aif}/*.questions.json | wc -l
clf: 0   soa: 0   dea: 0   mla: 0   aif: 0
$ grep -o '\*\*[^*]\+\*\*' assets/content/saa/*.questions.json | wc -l
20
```

**여섯 자격증 중 SAA만 20건**이다. 다른 다섯이 0건이라는 것은 이 표기가 **규율 위반이지 설계가 아님**을 보여 준다.
(같은 스캔에서 `[텍스트](링크)` 는 문항·md 모두 **0건**, 단일 `*이탤릭*` 은 **진성 0건**임을 확인했다 — §5-3.)

**5) 제안 수정안**

20개소에서 `**` 쌍을 제거한다(강조가 꼭 필요하면 문장 구조로 옮긴다). 예: `역할 정책과의 **교집합**으로` → `역할 정책과의 교집합으로`.

**기존 가드 충돌**: **없음.** 20개 구절을 전수 추출해 가드 테스트 25파일의 **주석 아닌 줄**과 대조한 결과, 가드가 단정하는 형태는 전부 **별표 없는 짧은 구절**이다 — `required: ['Transfer Family', '삭제할 때까지']`, `required: ['ElastiCache Serverless', '용량']`, `required: ['IP 기반', 'CIDR']` 등. `contains` 기반이므로 별표만 지우면 전부 그대로 통과한다.
(별표를 포함한 가드 2건 — `saa_question_propagation_test.dart:220`, `saa_t12_t13_facts_test.dart:124` — 은 `'키 정책의 **교집합**에서 접근이 허용'` 이라는 **다른 문장**을 `isFalse` 로 금지하는 것이라 무관하다.)

---

## 3. P2 — 출처 결함

### 3-1. 은퇴(이름 변경·병합) URL 4종 — 문항 8건 + md 7개소

> ⚠️⚠️ **컨트롤러 정정(2026-11-06 반영 PR — HANDOFF §0-2026-11-06-n).** 세 가지가 달라졌다.
> ① ⭐ **(a) Fargate 슬러그는 반영 시점에 이미 0건이었다** — 같은 날 먼저 돌아간 「CLF·DVA
> 죽은 출처 URL」 배치가 **레포 전수 33곳**을 고치며 **SAA 7곳까지** 함께 닫았다. 남은 결함은
> 이 절이 「부수 결함」으로 적은 **같은 URL에 출처 제목이 두 가지**(3:3)라는 것뿐이었고, 공식
> `h1` **`Architect for AWS Fargate for Amazon ECS`** 로 6건을 통일했다. **보고서는 그 사이에
> 고쳐진 것을 모르므로 반영 전에 전수로 다시 센다.**
> ② ⚠️⚠️ **(d)의 가드 충돌 지적이 정확했고, 판정 근거를 도착지로 확정했다** — 세 URL 모두
> `200 r=1`이라 `num_redirects`만으로는 「소멸」과 「이름 변경」이 갈리지 않는다. **도착지**를
> 보면 셋 다 **특정 페이지**로 가고 대조군 `…_zz-bogus.html` 만 **가이드 인덱스**로 간다 →
> 전부 이름 변경이다. `saa_gaps_b11_test.dart` 의 `isFalse` 를 뒤집고 대조군까지 주석에 적었다.
> ③ (b)(c)는 확정. 세 은퇴 URL을 `source_url_retired_test.dart` 의 전역 목록에 등재했다 —
> ⚠️ **옛 슬러그가 정본의 접두사**이지만 `.html` 까지 묶으면 부분 문자열이 되지 않는다(확인).

두 가지 방법이 **모두** 리다이렉트를 보고한 건이다(= 진짜 은퇴).

| # | 현재 URL | `curl -sL` | AWS 문서 리더 `redirected_url` | 정본 | 사용처 |
|---|---|---|---|---|---|
| a | `.../AmazonECS/latest/userguide/what-is-fargate.html` | `200 r=1` | **보고됨** | `.../AmazonECS/latest/developerguide/AWS_Fargate.html` | 문항 **6건** `saa-t2-2-q12·q13·q14` `saa-t3-4-q1·q3·q11` / md `saa-t2-2.md:22,430` |
| b | `.../amazondynamodb/latest/developerguide/HowItWorks.ReadWriteCapacityMode.html` | `200 r=1` | **보고됨** | `.../developerguide/capacity-mode.html` | 문항 **2건** `saa-t4-3-q9·q10` / md `saa-t4-3.md:16,477,501` |
| c | `.../IAM/latest/UserGuide/id_roles_terms-and-concepts.html` | `200 r=1` | **보고됨** | `.../IAM/latest/UserGuide/id_roles.html#id_roles_terms-and-concepts` | md `saa-t1-1.md:388` |
| d | `.../organizations/latest/userguide/orgs_manage_policies_declarative.html` | `200 r=1` | **보고됨** | `.../userguide/orgs_manage_policies_declarative_policies.html` | md `saa-t1-1.md:392` |

**부수 결함 (a)**: 출처 **제목**도 어긋난다. `saa-t3-4-q1·q3·q11` 은 제목을 `AWS Fargate — Architect for AWS Fargate for Amazon ECS` 로 적는데, 이것은 **리다이렉트 도착지의 제목**이다(리더가 읽어 온 `AWS_Fargate.html` 의 `h1` 이 `Architect for AWS Fargate for Amazon ECS`). 반면 `saa-t2-2-q12·q13·q14` 는 같은 URL에 `AWS Fargate — 소개 (공식)` 이라는 다른 제목을 단다. **같은 URL에 두 제목**이 붙어 있다.

**⚠️⚠️ (d)는 가드가 정본을 금지하고 있다 — 이번 검토에서 유일한 가드 충돌이다.**

`flutter_app/test/saa_gaps_b11_test.dart:211-213`:
```dart
test('죽은 declarative_policies 슬러그를 쓰지 않는다', () {
  expect(doc('saa-t1-1').contains('declarative_policies.html'), isFalse);
});
```
같은 파일 42-43줄 주석은 판정 근거를 이렇게 적는다 — *「`declarative_policies` → userguide 인덱스(**소멸**, 정본은 `orgs_manage_policies_declarative`)」*.

**이 판정은 지금 측정하면 반대다.** 실측:
- `orgs_manage_policies_declarative.html` → `200 r=1 -> …_declarative_policies.html`
- AWS 문서 리더도 `redirected_url: …orgs_manage_policies_declarative_policies.html` 을 **명시 보고**하고, 본문은 「Declarative policies in AWS Organizations」로 정상 제공된다.

즉 **`…_declarative_policies.html` 가 현재 정본이고, md가 들고 있는 `…_declarative.html` 가 은퇴 슬러그**다. B11 작성 시점의 판정이 뒤집혔거나(AWS가 다시 바꿨거나) 당시 판정이 반대였다. 어느 쪽이든 **가드가 틀린 판정을 굳히고 있다.**

**제안 수정안**: 네 URL을 정본으로 치환(문항 8건 + md 7개소). (a)의 출처 제목은 공식 `h1` 인 `Architect for AWS Fargate for Amazon ECS` 로 **6건 통일**.
(d)는 **가드부터 고친다** — `saa_gaps_b11_test.dart:212` 의 `isFalse` 를 `isTrue` 로 뒤집고 주석의 판정 서술을 교체한다. 가드를 그대로 두고 md만 고치면 테스트가 레드다.

**⚠️ 치환 주의**: 문항 JSON은 작업트리 CRLF·blob LF이므로 `json.dumps` 왕복 금지. `sources` 는 한 줄 압축 형식(`{ "title": …, "url": … }`)이라 전용 렌더러 + **치환 횟수 단정** + 손대지 않은 문항의 바이트 재현 대조군이 필요하다.

---

### 3-2. 백서 5종 — 「은퇴」가 아니라 「사람이 브라우저로 열 수 없음」 (판정을 두 번 했다)

`curl -sL` 로는 **전혀 다른 서비스 페이지로 튕긴다**. 여기서 멈췄다면 「백서 소멸」로 보고했을 것이다.

| 현재 URL (md 위치) | `curl -sL` 도착지 |
|---|---|
| `whitepapers/latest/building-data-lakes/in-place-querying.html` (`saa-t3-9.md:566`) | `lake-formation/latest/dg/what-is-lake-formation.html` |
| `whitepapers/latest/cost-modeling-data-lakes/cost-optimization-in-analytics-services.html` (`saa-t3-4.md:573`) | `cost-management/latest/userguide/what-is-costmanagement.html` |
| `whitepapers/latest/hybrid-cloud-dns-options-for-vpc/route-53-resolver-endpoints-and-forwarding-rules.html` (`saa-t3-8.md:512`) | `Route53/latest/DeveloperGuide/resolver.html` |
| `whitepapers/latest/hybrid-connectivity/aws-accelerated-site-to-site-vpn-aws-transit-gateway-single-aws-region.html` (`saa-t3-8.md:508`) | `directconnect/latest/UserGuide/Welcome.html` |
| `whitepapers/latest/patterns-for-ingesting-saas-data-into-aws-data-lakes/purpose-built-integration-service.html` (`saa-t2-1.md:38,414`) | `appflow/latest/userguide/what-is-appflow.html` |

**두 번째 방법이 판정을 뒤집었다.** AWS 문서 리더로 같은 5개 URL을 읽으면 **다섯 건 모두 `redirected_url: null` 이고 본문이 그대로 나온다**:

- `in-place-querying` → 「In-place querying」 본문 5,684자(Athena·Redshift Spectrum 절 포함)
- `route-53-resolver-endpoints-and-forwarding-rules` → 본문 3,516자, **인바운드/아웃바운드 엔드포인트 비교 표와 「엔드포인트당 약 10,000 QPS」 수치까지** 그대로
- `aws-accelerated-site-to-site-vpn-…` → 본문 1,752자, 「ECMP로 최대 50 Gbps」 포함
- `cost-optimization-in-analytics-services` → 본문 58,920자(TOC 포함)
- `purpose-built-integration-service` → 본문 4,008자(AppFlow 절)

**대조군**: 같은 리더로 틀린 슬러그 `sagemaker/latest/dg/zz-bogus-control.html` 을 읽으면 `redirected_url` 이 **보고된다**. 즉 리더가 리다이렉트를 숨기지 않는다는 것이 확인됐으므로, 위 다섯 건의 `null` 은 「리다이렉트 없음」을 뜻한다.

**판정**: 백서는 **살아 있고 인용도 유효**하다. 결함은 **학습자가 참고자료 링크를 누르면 전혀 다른 서비스 페이지에 떨어진다**는 것이다.

**제안 수정안**: 인용을 **지우지 않는다**(참인 인용을 지우는 것이 더 나쁘다). 대신 참고자료 항목에 상태를 명시한다 — 예: `… (백서 본문은 유효하나 브라우저 접근 시 서비스 페이지로 리다이렉트됨 · 2026-11-06 실측)`. 사람이 열 수 있는 인접 정본을 **병기**하는 것도 가능하다(위 표의 도착지 페이지들이 바로 그 후보다).

**기존 가드 충돌**: 없음.

---

### 3-3. `saa-t1-4-q13` — 인용한 페이지의 **첫 문장이 문항과 반대**로 적는다

**1) 위치** `saa-t1-4.questions.json` — `saa-t1-4-q13` (`verified:true`, `correct: 2`)

**2) 현재 문구**

정답 보기 / 해설:
> Shield Standard는 **L3/L4 DDoS를 자동 완화**하고, Shield Advanced는 L3/L4에 더해 **L7 애플리케이션 계층 DDoS 자동 완화를 추가 제공**한다

출처: `How AWS Shield and Shield Advanced work (공식)` — <https://docs.aws.amazon.com/waf/latest/developerguide/ddos-overview.html>

**3) 왜 문제인지**

인용한 바로 그 페이지의 **첫 문단**이 이렇게 적는다:

> **AWS Shield Standard and AWS Shield Advanced** provide protections against Distributed Denial of Service (DDoS) attacks for AWS resources at the network and transport layers (layer 3 and 4) **and the application layer (layer 7)**.

즉 이 페이지는 **Standard와 Advanced를 묶어** L3/L4 **및** L7을 말한다. 문항의 갈림길(「Standard=L3/L4, Advanced가 L7 추가」)을 이 페이지에서 끌어낼 수 없고, 오히려 반증처럼 읽힌다.

**4) 공식이 갈리는 자리 — 양쪽 URL**

| 페이지 | 적는 것 |
|---|---|
| `waf/latest/developerguide/ddos-overview.html` (현재 출처) | Standard와 Advanced가 **함께** L3/L4 + L7 보호를 제공 |
| `waf/latest/developerguide/ddos-standard-summary.html` (**더 구체적인 전용 페이지**) | *「Shield Standard defends against **the most common, frequently occurring network and transport layer** DDoS attacks」* / Route 53·CloudFront·Global Accelerator에 대해 *「comprehensive availability protection against **all known network and transport layer** attacks」* |
| `prescriptive-guidance/latest/security-reference-architecture/network.html` | *「Shield Standard provides … protection against the most common **infrastructure (layers 3 and 4)** events」* + **L7 자동 완화는 Shield Advanced 기능**으로 분리 기술 |

**규율 5-5 적용**: 더 구체적인 전용 페이지(`ddos-standard-summary`)와 SRA가 일치하므로 **문항의 판정은 유지**한다. 결함은 **출처 선택**이다.

**5) 제안 수정안**

`saa-t1-4-q13` 의 출처를 **`ddos-standard-summary.html` 로 교체**(또는 병기)한다. 본문·정답 인덱스 불변.
⚠️ 같은 Task의 **`saa-t1-4-q2`·`q3`·`q12`·`q15` 도 같은 `ddos-overview.html` 을 쓴다**(전수 확인: 이 URL을 쓰는 문항은 `q2`·`q3`·`q12`·`q13`·`q15` 다섯 건). 그 네 건이 인용하는 사실은 「Shield Standard가 추가 설정 없는 무료 방어」(`q2`) · SRT 24/7·요금 보호(`q3`) · 엣지 WAF 배치 이점(`q12`, 보조 출처) · L3/L4↔Shield 매핑(`q15`)이고, 모두 이 페이지의 공격 분류(L3 볼류메트릭 / L4 프로토콜 / L7 애플리케이션)와 목차(`AWS Shield Standard overview`·`AWS Shield Advanced overview`)에 부합하므로 **교체 대상이 아니다**. 문제가 되는 것은 **Standard와 Advanced의 계층 경계를 이 페이지 하나로 증명하려 한 `q13`뿐**이다.

**기존 가드 충돌**: 없음.
**참고**: `saa-t1-4.md` 쪽은 **이미 정확하다** — 58줄이 「Shield는 **DDoS(L3/L4/L7)** 방어」로 상위 페이지 서술을, 158·175줄이 「Standard는 L3/L4, Advanced가 L7 자동 완화 추가」로 전용 페이지 서술을 각각 올바른 층에 둔다. md 선결 불필요.

---

### 3-4. 경미한 URL 드리프트 3건

| 현재 URL | 실측 | 정본 | 사용처 |
|---|---|---|---|
| `https://aws.amazon.com/directconnect/pricing/` | `200 r=1` | `…/directconnect/pricing/pay-as-you-go/` | 문항 `saa-t4-4-q13·q14` / md `saa-t4-4.md:22,427` |
| `https://aws.amazon.com/network-firewall/faqs` | `200 r=1`(후행 슬래시) | `…/network-firewall/faqs/` | md `saa-t1-3.md:40,468` |
| `https://docs.aws.amazon.com/databases-on-aws-how-to-choose/` | `200 r=1` | `…/decision-guides/latest/decision-guides/databases-on-aws-how-to-choose.html` | md `saa-t3-6.md:20,461` |

셋 다 **죽은 링크가 아니다**(정상 도착). 정본으로 맞추는 선택적 정리.

---

## 4. P3 — 보강 후보

### 4-1. 정답 인덱스 쏠림 — 학습자에게는 안 보이지만 저작 기계성의 신호

전수 집계(360문항):

```
전체 correct 분포: {0: 45, 1: 165, 2: 99, 3: 51}
saa-t1-1: {1: 15}            ← 15/15 (100%)
saa-t2-1: {1: 15}            ← 15/15 (100%)
saa-t2-4: {1: 13, 2: 2}      ← 13/15
saa-t3-1: {1: 13, 2: 2}      ← 13/15
saa-t3-2: {1: 10, 2: 5}      saa-t3-3: {1: 5, 2: 10}      saa-t3-7: {1: 10, 2: 5}
```

**학습자에게는 보이지 않는다** — 네 렌더 경로가 **모두** 보기를 셔플한다(실측):
`lib/pages/quiz_page.dart:41` · `lib/pages/review_page.dart:77` · `lib/pages/exam_page.dart:101` · `lib/pages/cert_exam_page.dart:193` → 전부 `applyOptionOrders(…, randomOptionOrders(…, rng))`.

그러므로 **P1이 아니다.** 다만 t1-1·t2-1이 15/15로 한 자리에 몰린 것은 두 Task가 한 틀로 기계 저작됐다는 신호이고, 실제로 이 두 Task의 미검수 문항(각 10·9건)은 「보기 넷 중 셋이 명백한 금지 패턴(루트 키 공유·퍼블릭 개방)」인 구조가 반복된다. 난이도 균형 보강 시 참고.

### 4-2. 오답 보기의 「명백 금지」 쏠림 — 변별력

위와 이어진다. `saa-t1-1-q2·q3·q4`, `saa-t1-4-q9` 등에서 오답 3개 중 2개가 「루트 사용자 자격증명 공유/배포」·「S3 버킷을 퍼블릭으로 개방」이다. 공식 가이드는 *「정답 이외의 답은 일반적으로 콘텐츠 영역에 부합하여 **맞아 보이는** 응답」* 이라고 적는다(<https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html>, 「답안 유형」 절). 지금 구조는 그 기준보다 쉽다.

### 4-3. 범위(D축) — 정답 보기 2건이 공식 「범위 내」 목록에 없다

공식 「범위 내 AWS 서비스」를 **실측 전수**로 받아(<https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/saa-03-in-scope-services.html>, `200 r=0`) 360문항의 **정답 보기** 서비스명과 기계 대조했다. 목록과 매칭되지 않는 것 5건:

| 정답 보기의 이름 | 문항 | 판정 |
|---|---|---|
| **AWS Elastic Disaster Recovery** | `saa-t2-5-q10` | 공식 「마이그레이션 및 전송」 목록은 **Application Migration Service·DataSync·DMS·Snow Family·Transfer Family** 다섯뿐 — **DRS 없음** |
| **Amazon Timestream for InfluxDB** | `saa-t4-3-q13` | 공식 「데이터베이스」 목록 9종(Aurora·Aurora Serverless·DocumentDB·DynamoDB·ElastiCache·Keyspaces·Neptune·RDS·Redshift) — **Timestream 없음** |
| AWS Graviton | `saa-t3-3-q1` | 서비스가 아니라 EC2 프로세서 — 문제 없음 |
| AWS SCT | `saa-t3-5-q3` | DMS 구성요소 — 위험 낮음 |
| AWS Cost Anomaly Detection | `saa-t4-5-q4` | AWS Cost Management 기능 — 위험 낮음 |

⚠️ **규율 5-4 적용**: 목록 머리말이 *「이 목록은 전체 목록이 아니며 변경될 수 있습니다」* 라고 적으므로 **「목록에 없다」가 「범위 밖」은 아니다.** 그래서 P1이 아니라 P3다. 다만 **정답 보기**로 쓸 때는 목록에 든 이름을 우선하는 쪽이 안전하고, 특히 `saa-t4-3-q13` 은 **오답 셋이 전부 목록에 든 서비스**(Aurora Serverless·RDS·DynamoDB)라 비대칭이 크다.

**부수 실측 — 가이드가 갱신됐다**: 현재 공식 「데이터베이스」 목록은 **9종이고 QLDB가 없다**. 레포 기록(메모리)은 10종·QLDB 포함으로 남아 있다. 콘텐츠에 QLDB 언급은 **0건**이라 영향은 없지만, 가이드 재추출 시점을 잡을 근거다.
**부수 실측 2**: 합격 최소 점수는 공식 가이드 기준 **720점**이다.

### 4-4. 닫힌 서비스 처리는 **모범적**이다 (대조군으로 기록)

D축에서 찾은 것 중 실제로 문제인 것은 없었다. 오히려 두 건이 교과서적이다:
- `saa-t3-9-q11` — 지문이 *「이 회사는 이미 AWS Snowball Edge를 사용 중인 **기존 고객**이다」* 로 조건을 세우고, 해설이 *「Snowball Edge는 **신규 고객에게 더 이상 제공되지 않습니다**」* + 신규 대안(DataSync·Data Transfer Terminal·Outposts)까지 적는다. 출처도 가용성 변경 공지다.
- `saa-t4-3-q13` — 정답을 **닫히지 않은 쪽**(`Timestream for InfluxDB`)으로 두고, 해설이 *「Timestream for LiveAnalytics는 2025-06-20부터 신규 고객 접근이 닫혔으므로」* 를 명시한다.

전수 스캔(Timestream·Snowball Edge·Kinesis Data Analytics·Forecast·CodeGuru·SimpleDB·Elastic Transcoder·CloudSearch·Data Pipeline·OpsWorks·Cloud9·CodeCommit 외 20종)에서 **무처리 사용 0건**.

### 4-5. 지역 미한정 절대 요금 6종

`saa-t4-4` 문항이 지역 한정 없이 단가를 단정한다:

| 문항 | 문구 |
|---|---|
| `saa-t4-4-q3` | `시간당 가용 요금($0.045/시간/AZ)`, `데이터 처리 요금($0.045/GB)` |
| `saa-t4-4-q5` | `교차 AZ 전송 요금($0.01/GB)` |
| `saa-t4-4-q13` | `Direct Connect 아웃바운드 단가(약 $0.02/GB)`, `인터넷 아웃바운드(약 $0.09/GB)`, `포트 시간 요금($0.30/시간 등)` |

수치 자체는 us-east-1 기준으로 맞지만, **레포는 같은 종류의 단가를 이미 한 번 지웠다** — #264 기록: *「확인 불가였던 아웃바운드 단일 단가는 지웠다 — 공식은 "charged per service, with rates specific to the originating Region" 까지만 말한다」*. 또한 `aws.amazon.com/*/pricing/` 의 요율 표는 JS로 그려져 **본문 추출에 나오지 않으므로**(이번에도 `cloudfront/pricing` 본문에 요율 표 대신 정액제 표만 나왔다) 인용 페이지에서 그 수치를 확인할 수 없다.

**제안**: `(US East(버지니아 북부) 기준 · 리전마다 다름)` 을 병기하거나, 비교 구조(「DX 아웃바운드가 인터넷 아웃바운드보다 낮다」)만 남기고 절대값을 뺀다.

### 4-6. `saa-t4-4-q5` — 교차 AZ 단가는 「each way」다

> AZ-B → AZ-A 경로에 **교차 AZ 전송 요금($0.01/GB)** 이 NAT 처리 요금($0.045/GB)에 추가로 붙습니다.

AWS는 교차 AZ 전송을 **양방향 각각** $0.01/GB로 과금한다(레포가 이미 확인한 사실 — EKS 비용 최적화 가이드가 `each way` 로 적는다). 왕복이 일어나는 NAT 경유 시나리오에서 추가분은 **$0.02/GB**에 가깝다. 수치를 쓸 거라면 방향을 명시해야 한다.

### 4-7. `saa-t3-8-q4` — 두 터널 「부하 분산」은 공식 문구보다 한 걸음 나간다

> 두 터널을 동시에 활성화하면 **부하 분산**도 가능합니다.

공식(<https://docs.aws.amazon.com/vpn/latest/s2svpn/VPC_VPN.html>, `200 r=0`, 전문 확인)은
> Each VPN connection includes two VPN tunnels which you can **simultaneously use for high availability**.

**「동시 사용」까지는 공식이 적지만 「부하 분산」은 적지 않는다.** 터널 간 ECMP 부하 분산은 **Transit Gateway 연결**에서 성립하는 별개 조건이다(같은 페이지가 TGW를 별도 개념으로 분리한다). 정답 보기·인덱스는 영향 없고 해설 한 문장만 좁히면 된다.

### 4-8. 과도한 일반화 소형 4건 (사실 영역)

전수 스캔 결과 사실 영역의 단정어는 `할 수 없습니다` 53 · `항상` 29 · `반드시` 20 · `불가능합니다` 11 · `전혀` 8 · `절대` 4 · `유일한 방법` 1 이다. 대부분 문맥상 정당하고, 아래 넷만 좁힐 가치가 있다.

| 위치 | 문구 | 왜 |
|---|---|---|
| `saa-t1-3-q5` 왜아님[1] | 「특정 IP 차단은 **반드시** NACL을 사용해야 합니다」 | WAF IP set·Network Firewall도 IP를 차단한다. 보기 집합 안에서는 NACL이 정답이지만 단정은 과하다 |
| `saa-t4-4-q7` 왜아님[0] | 「비용 관점에서 S3를 Interface Endpoint로 쓸 **이유가 없습니다**」 | 온프레미스에서 DX·VPN 경유로 S3에 닿으려면 Interface Endpoint가 필요하다. 같은 계열 오류가 `saa-t1-3-q10` 에서 이미 한 번 정정됐다 |
| `saa-t3-4-q5` 해설 | 「메모리 설정이 **유일한** 성능 손잡이입니다」 | 아키텍처(arm64/x86) 선택도 성능·비용 손잡이다 |
| `saa-t3-2.md:137` | 「AZ 간 이동이 필요할 때는 스냅샷을 통한 복사가 **유일한 경로**가 됩니다」 | **볼륨**의 AZ 이동은 맞지만 **데이터**의 AZ 이동은 인스턴스 간 네트워크 복사 경로가 있다 |

### 4-9. 출처가 전부 「소개 페이지」인 문항 92건 (미검수 65건)

전수 집계:

```
문항 총수                                          360
출처가 1개뿐인 문항                                 265
출처가 전부 소개(welcome/what-is/Introduction) 페이지  92
  그중 가드 미언급(2차 검수 미거침)                    65
```

레포는 2026-10-27 §D에서 **바로 이 패턴**으로 62문항(공개 16 + 드래프트 46)의 출처를 교체했다(*「사실은 맞는데 인용 페이지가 그 사실을 담고 있지 않던 경우이고 대부분 서비스 소개 페이지였다」*). 남은 **92건, 특히 미검수 65건**이 같은 작업의 잔여다.

⚠️ **「소개 페이지 = 틀린 출처」는 아니다.** 이번에 두 건을 실측으로 기각했다:
- `saa-t3-6-q1·q6` 의 `amazondynamodb/.../Introduction.html` — 「serverless, fully managed, distributed NoSQL database with single-digit millisecond performance at any scale」와 **온디맨드 용량 모드 설명**이 그 페이지 본문에 **실재한다**(전문 17,406자 중 확인).
- `saa-t4-4-q8·q9` 의 `aws.amazon.com/cloudfront/pricing/` — 「오리진→CloudFront 전송 무료」는 현재 페이지에 *「Data transfer between CloudFront and your AWS origins is automatically **waived** when serving traffic through CloudFront」* 로 **있다**.

그래서 이 항목은 「92건을 일괄 교체하라」가 아니라 **「92건을 한 건씩 재면 몇 건은 교체 대상」** 이라는 작업량 추정이다. 우선순위는 **수치·상한·기본값을 단정하는 문항**이다(소개 페이지가 그런 수치를 담는 일은 드물다).

---

## 5. 확인했고 문제 없던 것 — 대조군

「검토했다」의 증거다. **특히 5-2는 내 판정이 틀렸다가 실측으로 바로잡힌 자리**이고, 이 보고서에서 가장 값이 큰 부분이다.

### 5-1. 측정 자체의 유효성

| 확인 | 결과 |
|---|---|
| URL 측정 대조군 5종 | 전부 명세대로(§1) → 측정 유효 |
| AWS 문서 리더 대조군(틀린 슬러그) | `redirected_url` 보고됨 → 리더 신호 신뢰 가능 |
| `repost.aws` 403 3건 | **봇 차단, 전부 살아 있음.** 내장 브라우저로 세 URL을 직접 열어 본문 확인 — `rds-stop-seven-days`(「By default, you can stop an Amazon RDS DB instance for up to seven days at a time」), `lambda-reduce-costs`, `ARg2nreO9URO…`(ML 서비스 결정 프레임워크) |
| `curl` 487건 중 404 | **0건** |

### 5-2. ⚠️ 내 판정이 틀렸다가 공식 실측으로 뒤집힌 자리 — **8건**

사전 지식으로 「틀렸다」고 의심했으나 **공식이 문항 편이었다**. 그대로 보고했다면 전부 거짓 양성이었다.

| # | 내 의심 | 실측 결과 | 근거 |
|---|---|---|---|
| 1 | `saa-t4-2-q2` 「Convertible RI 최대 **66%**」 → 54%여야 한다 | **문항이 맞다.** 공식 EC2 RI 페이지: *「Convertible RIs: These provide a discount (**up to 66% off On-Demand**)」*. 내가 떠올린 54%는 같은 페이지 Details 표의 **3년 평균 할인**이고, `saa-t4-2.md:79` 는 **둘 다**(「최대 66% (3년 평균 약 54%)」) 정확히 적고 있었다 | <https://aws.amazon.com/ec2/pricing/reserved-instances/> |
| 2 | `saa-t4-5-q1` 「향후 **18개월** 예측」 → 12개월일 것 | **문항이 맞다.** *「You can view data for up to the last 13 months, forecast how much you're likely to spend for the next **18 months**」* | `cost-management/.../ce-what-is.html` |
| 3 | `saa-t3-2-q3` 「gp3 최대 **80,000 IOPS**」 → 16,000일 것 | **문항이 맞다.** 공식 표: gp3 Max IOPS **80,000**(25.6 KiB I/O), Max throughput **2,000 MiB/s**. gp2가 16,000이다 | `ebs/.../ebs-volume-types.html` |
| 4 | `saa-t3-3-q4` 「`unlimited` 모드(**T8i**·T4g·T3a·T3의 기본값)」 → T8i는 없는 유형일 것 | **문항이 맞다.** *「The EC2 burstable instances consist of **T8i**, T4g, T3a, and T3 …」* + *「**T8i, T4g, T3a, and T3** instances launch as `unlimited` by default」* — 네 유형 목록까지 정확히 일치 | `AWSEC2/.../burstable-performance-instances.html` + `…-unlimited-mode.html` |
| 5 | `saa-t3-9-q14` 「현재 용량 모드는 **On-demand Standard · On-demand Advantage · Provisioned 3종**」 → Advantage는 없을 것 | **문항이 맞다.** 공식: *「you can choose **On-demand Standard**, **On-demand Advantage**, and **Provisioned** as the mode」* | `streams/latest/dev/how-do-i-size-a-stream.html` |
| 6 | `saa-t2-3-q2` 「NLB는 TCP/UDP/TLS/**QUIC** 을 모두 지원」 → QUIC는 NLB 프로토콜이 아닐 것 | **문항이 맞다.** *「Network Load Balancer target groups support the TCP, UDP, TCP_UDP, TLS, **QUIC**, and TCP_QUIC protocols」* | `elasticloadbalancing/latest/network/introduction.html` |
| 7 | `saa-t3-5-q7` 「Aurora Global Database … 최대 **10개** 보조 리전」 → 5개일 것 | **문항이 맞다.** *「An Aurora global database has a primary DB cluster in one Region, and **up to 10 secondary DB clusters**」* | `AmazonRDS/.../aurora-global-database.html` |
| 8 | `saa-t4-4-q8·q9` 「오리진→CloudFront 전송 무료」의 출처가 현재 페이지에 없을 것 | **출처가 유효하다.** 현재 CloudFront 요금 페이지에 *「Data transfer between CloudFront and your AWS origins is automatically waived…」* 가 있다 | <https://aws.amazon.com/cloudfront/pricing/> |

### 5-3. 기계 스캔에서 깨끗했던 것

| 축 | 측정 | 결과 |
|---|---|---|
| G 표기 | 문항·md 전수 `[텍스트](링크)` | **0건** (전역 규율 유지) |
| G 표기 | 단일 `*이탤릭*` | 정규식 1차 7건 → **전수 확인 결과 진성 0건**. 전부 `/api/*`·`/static/*`·`kinesis:List*` 같은 **글로브 와일드카드 오탐**(`saa-t2-3-q1`, `saa-t3-7-q15`, `saa-t2-3.md:457,461`, `saa-t3-9.md:435`) |
| G 표기 | 서비스명 한글 음차(람다·다이나모·레드시프트 외 14종) | 문항 **0건**, md 1건(`람다` — 문맥 확인 결과 서비스명 아님) |
| F 메모 | 작성 과정 메모(「확인되지 않」·「원문에 나오지 않」·「추정」·「검수 반영」 외 14패턴) | 정규식 4건 → **전수 확인 결과 진성 0건**. 「최후 **작성자** 우선(last-writer-wins)」·「10배 과대 **추정**」·「세 항목 모두 실제 S3 요금 항목입니다」로, 모두 정당한 사실 서술. **M2 가드가 제 일을 하고 있다** |
| 구조 | 보기 개수 | 360문항 **전부 4지선다** |
| 구조 | `verified` | 360/360 `true` (flip은 사람 전용이므로 **건드리지 않았다**) |
| D 범위 | 닫힌·은퇴 서비스 32종 전수 | 무처리 사용 **0건**(§4-4) |
| E 일관성 | 전파 가드 금지 문구 56개 × md 24편 | 유효 탈출 **1건**(P1-1). 나머지 3건은 정정문 자체의 인용 1건 + **다른 사실**의 우연 일치 2건(`saa-t4-3.md:219,499` 의 `최대 54%` 는 **DynamoDB 예약 용량 1년 할인율**이지 Convertible RI가 아니다) |

### 5-4. 공식 대조에서 「맞다」로 확인한 주요 사실 (발췌)

미검수 178문항을 정독하며 공식 원문과 맞춘 것 중, 비자명해서 기록할 가치가 있는 것:

- **배치 그룹**: Spread는 「AZ당 최대 7개 **실행 인스턴스**」, 3개 AZ면 총 21개, 8번째는 시작 실패 / Partition은 「AZ당 최대 7개 **파티션**」이고 인스턴스 수는 계정 한도만 따른다 / 클러스터 단일 플로우 **10 Gbps** / Spread는 **Dedicated Instances 미지원** — `saa-t3-3-q10·q11·q12·q13`, `saa-t3-4-q9` 전부 공식 표현과 일치(`AWSEC2/.../placement-strategies.html` 전문 12,300자 확인). **내가 「7개 인스턴스는 파티션의 오기일 것」이라 의심했다가 기각한 자리다.**
- **Fargate**: 「각 태스크가 자체 격리 경계를 가지며 커널·CPU·메모리·ENI를 공유하지 않는다」가 공식 문장 그대로(`Each Fargate task has its own isolation boundary and does not share the underlying kernel, CPU resources, memory resources, or elastic network interface with another task`) — `saa-t3-4-q11` 일치. **GPU 미지원**도 확인(`GPUs aren't available for jobs that are running on Fargate resources` + ECS GPU는 EC2/외부 인스턴스 전용) — `saa-t2-2-q12` 일치.
- **RDS 예약 인스턴스**: 「No Upfront는 **1년 예약으로만** 제공」(`This option is only available as a one-year reservation`) → `saa-t4-3-q3` 왜아님[1] 일치 / 「Multi-AZ↔Single-AZ는 같은 인스턴스 클래스 타입 안에서 자유롭게 오갈 수 있다」(`you can move freely between configurations within the same DB instance class type`) → `saa-t4-3-q4` 일치 / 「리전·엔진·클래스가 사양」 → 리전 불일치 시 미적용 일치.
- **Graviton**: 「동급 x86 대비 **최대 20% 저렴**」이 공식 문구 그대로(`AWS Graviton-based instances cost up to 20% less than comparable x86-based Amazon EC2 instances`) → `saa-t4-2-q14` 와 `saa-t4-2.md` 의 2026-10-19 정정이 정확.
- **Savings Plans 비교 표**: Compute SP 66% / EC2 Instance SP 72% / Convertible RI 66% / Standard RI 72% → `saa-t4-2.md:78-81` 네 행 전부 일치.
- **S2S VPN**: 「각 VPN 연결에 터널 2개」 공식 일치(`saa-t3-8-q4`).
- **ASG 수명 주기 훅**: 기본 대기 1시간·최대 48시간(`saa-t2-3-q11`), 최소 용량이 스케일 인 하한(`saa-t2-3-q7`), 혼합 인스턴스 정책은 시작 템플릿 전용(`saa-t2-3-q14`).
- **S3**: Intelligent-Tiering 30일→IA·90일→Archive Instant Access·검색 요금 없음·최소 보관 기간 없음·**128 KB 미만 모니터링 제외**(`saa-t3-1-q2`, `saa-t4-1-q2`) / Standard-IA 30일·GIR·GFR 90일·Deep Archive 180일(`saa-t3-1-q5`) / **프리픽스당 5,500 GET/HEAD**(`saa-t3-1-q10`) / Storage Lens 무료 14일·고급 15개월(`saa-t4-1-q13`).
- **DynamoDB 보조 인덱스**: GSI 최종 일관성·독립 처리량·언제든 추가 / LSI 강력 일관성 가능·처리량 공유·생성 시에만 — `saa-t3-6-q3·q4` 네 축 전부 일치.
- **EFS**: 「Windows 인스턴스 미지원」 공식 일치, Max I/O는 이전 세대이며 Elastic 처리량 미지원(`saa-t3-2-q9·q12`).
- **SCP**: 관리 계정 미적용 · 서비스 연결 역할 예외 · 루트→OU→계정 누적 교집합(`saa-t1-2-q3·q4·q6`).

### 5-5. 학습문서에서 확인한 강점 (수정 불필요)

- **`saa-t3-2.md` 의 EBS 절은 현행 공식과 완전히 일치한다** — gp3 80,000/2,000 MiB/s, io2 256,000(Nitro 전용·그 외 32,000·볼륨은 64,000까지 연결), gp2 16,000/250 MiB/s, st1 500 IOPS·500 MiB/s, sc1 250/250. 심지어 *「일부 SDK 문서(ECS 관리형 볼륨 등)는 gp3 IOPS 범위를 `3,000–16,000` 으로 적는데, **EBS 사용자 가이드의 80,000이 볼륨 자체의 상한**입니다」* 라는 공식 내부 불일치까지 명시한다(191줄).
- **`saa-t2-4.md`·`saa-t3-5.md` 의 Multi-AZ 서술은 배포 유형 둘을 정확히 가른다**(P1-3의 반증 근거가 된 그 줄들).
- **`saa-t1-4.md` 의 Shield/WAF 층위**가 상위 페이지 서술과 전용 페이지 서술을 올바른 층에 분리해 둔다(§3-3).
- **`saa-t4-2.md:102`** 가 SP 우선순위 단정을 명시적으로 부정하는 경고 박스를 갖고 있다(P1-1이 그 경고를 어긴 한 줄이다).

---

## 6. 측정 한계 — 못 본 것과 그 이유

1. **가드가 언급하는 182문항은 정독하지 않았다.** 2차 검수가 닿은 문항이라 중복 보고 위험이 크고, §0-1의 설계대로 미검수 178건에 깊이를 썼다. 다만 **기계 스캔(표기·메모·쏠림·일반화·범위·출처·닫힌 서비스)은 360건 전수**에 걸었으므로, 그 축의 결함은 182건에서도 잡혔을 것이다. 잡히지 않는 것은 **182건의 개별 사실 오류**다.

2. **학습문서 24편을 통독하지 않았다.** 통독은 4편(`saa-t2-4`·`saa-t3-2`·`saa-t3-5`·`saa-t4-2`)이고 나머지 20편은 **겨냥 검사**(전파 가드 금지 문구 전수 대조 · 출처 URL 전수 실측 · 특정 defect class grep)만 했다. 1.08 MB를 제대로 읽으려면 별도 1회차가 필요하다. **자가 점검 블록 24편 전수 대 본문 모순 검사**는 P1-1·P1-2가 모두 그 블록에서 나온 만큼 **다음 회차의 1순위**로 권한다.

3. **「정답이 둘이거나 없는 문항」을 기계로 탐지하지 못했다.** 이 판정은 보기 네 개의 참/거짓을 각각 공식과 맞춰야 성립하므로 자동화 불가다. 미검수 178건은 정독하며 눈으로 봤고, 그 범위에서 「정답이 둘」로 판정한 건은 없다. 다만 **정독만으로는 놓칠 수 있다** — 2차 검수가 `saa-t2-3-q4`(교차 영역 분산)를 「정답 보기가 거짓이라 맞는 보기가 하나도 없음」으로 찾아낸 선례가 있다.

4. **`saa-t2-4-q1` 의 HA/내결함성/DR 정의 귀속을 확정하지 못했다.** 문항은 출처로 Reliability Pillar를 달고 「HA는 짧은 중단 후 자동 복구, 내결함성은 완전 무중단」이라는 분류를 제시하는데, 이것이 공식 정의인지 저작자 분류인지 판정하려면 Reliability Pillar 전문(수십만 자)을 훑어야 해서 이번 회차에 넣지 못했다. **「공식에 없다」 규율을 다 채우지 못했으므로 §2·§3에 올리지 않았다.** 다음 회차 확인 대상.

5. **`saa-t3-9-q5`(Firehose→Redshift가 S3 경유 COPY)를 재확인하지 못했다.** Firehose의 Redshift 목적지 경로는 최근 변화가 잦은 영역인데, 인용 페이지(`firehose/.../what-is-this-service.html`)에서 해당 서술을 찾지 못했다. **「없다」 규율 5단계를 다 적용하지 않았으므로 결함으로 보고하지 않는다.** 다음 회차 확인 대상.

6. **요금 페이지의 실제 요율을 검증하지 못했다.** `aws.amazon.com/*/pricing/` 의 요율 표는 JS로 그려져 본문 추출에 나오지 않는다(이번 `cloudfront/pricing` 추출에서도 정액제 표만 나왔다). §4-5의 단가 6종은 **「인용 페이지 본문에서 확인 불가」까지만** 판정했고, 「수치가 틀렸다」고는 말하지 않는다.

7. **`flutter test`·`flutter analyze` 를 돌리지 않았다**(과제 지시). 제안 수정안의 가드 충돌은 **정적 대조**(가드 파일의 주석 아닌 줄과 문구 전수 매칭)로만 확인했다. 컨트롤러가 수정 PR에서 실제 실행으로 재확인해야 한다.

8. **`docs/saa-review/` 에 SAA 2차 검수 보고 전문이 없다.** 그래서 「이미 닫힌 항목」의 정본을 **가드 테스트 코드·주석**에서 역추출했다. 가드가 걸지 않은 채 보고서에만 있었던 항목(예: 보고가 「확인 필요」로 남긴 것)은 이 방법으로 보이지 않는다. 그런 잔여가 있다면 이 보고서에 **중복으로 올라왔을 수 있다.**

---

## 부록. 재현 명령

```bash
# 가드 커버리지 (182/178 분할)
grep -ohE 'saa-t[0-9]+-[0-9]+-q[0-9]+' flutter_app/test/saa*.dart | sort -u | wc -l

# 문항 굵게 표기 — SAA 대 타 자격증 대조군
for d in saa clf soa dea mla aif; do \
  printf "%s: %s\n" "$d" "$(grep -o '\*\*[^*]\+\*\*' flutter_app/assets/content/$d/*.questions.json 2>/dev/null | wc -l)"; done

# 전파 가드 금지 문구가 md에 살아 있는지 (P1-1 재현)
grep -n '먼저 고려하도록 권장' flutter_app/assets/content/saa/*.md

# 부팅 볼륨 자기모순 (P1-2 재현)
grep -n '부팅 볼륨은 SSD\|standard` 루트 볼륨' flutter_app/assets/content/saa/saa-t3-2.md
```

URL 실측은 **명령문에 URL을 리터럴로** 써야 한다(§0-4):

```bash
curl -sL -o /dev/null -m 30 -w "%{http_code} r=%{num_redirects} -> %{url_effective}\n" "https://docs.aws.amazon.com/AmazonECS/latest/userguide/what-is-fargate.html"
```
