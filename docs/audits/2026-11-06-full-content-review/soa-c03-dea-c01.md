# SOA-C03 · DEA-C01 콘텐츠 전수 검토 (2026-11-06)

_네 세션 분담 검토 중 **SOA-C03 + DEA-C01** 담당분. 합쳐 **라이브 문항 556개**(SOA 300 + DEA 256)와 **라이브 학습문서 37편**(SOA 20 + DEA 17)이 대상이며, 전부 `verified: true`로 학습자에게 노출 중이다._

> **이 검토는 파일을 하나도 바꾸지 않았다.** 산출물은 이 보고서뿐이고, 수정·커밋·flip은 컨트롤러와 사람의 몫이다.
> 모든 판정은 **조사 노트·과거 감사 보고가 아니라 공식 AWS 문서 실측**으로 세웠다. 아래 모든 항목에 공식 URL과 그 페이지가 적는 문장을 함께 붙였다.

---

## 0. 검토 계획

사용자가 명시적으로 요청한 산출물이므로 **실행 전에 세운 계획**을 먼저 적고, 실행하며 달라진 점을 ⟲ 로 덧붙였다.

### 0-1. 왜 이 순서인가

분량이 네 세션 중 가장 많으므로(556문항 · 1.19MB md) **"얕게 다 보기"를 버리고 "기계로 전수 + 사람 눈으로 전수 + 공식 실측은 위험 순"** 세 층으로 쪼갰다. 기계 패스는 싸고 전수이므로 먼저 돌려 범위를 좁히고, 비싼 공식 문서 실측은 기계 패스와 통독이 지목한 곳에만 쓴다.

| 단계 | 대상 | 방법 | 비용 |
|---|---|---|---|
| ① 기계 전수 | 556문항 + 37편 | 집계 스크립트 · grep | 싸다 |
| ② URL 전수 | 고유 URL 1,208개 | `curl -sL` 병렬 | 중간(백그라운드) |
| ③ 사람 통독 | 556문항 전수 | 덤프 후 정독 | 비싸다 |
| ④ 공식 실측 | ①③이 지목한 것 | AWS 문서 리더 | 가장 비싸다 |

### 0-2. 단계별 측정 명령과 판정 기준

**① 기계 전수 패스** — 다음을 전수로 센다. 각 항목은 "0이어야 한다"는 기대값을 먼저 정하고 실측했다.

```sh
# 정답 인덱스 분포 · 보기 수 · 작성 과정 메모 · 지문 중복 · 보기 중복 · 고유 URL
py agg.py                     # soa/dea 각각
# 파서 미지원 표기(G축): [텍스트](링크) · 단일 *이탤릭*
# 구식·닫힌 서비스 명칭(D·G축): 22종 사전 대조
py mech.py
```

⚠️ **탐지기 자체를 먼저 대조군으로 검증했다.** 「0건」이 「탐지기가 고장났다」일 수 있으므로, 링크·이탤릭 정규식에 **일부러 걸리는 문자열 4종**을 넣어 `LINK=True / ITAL=1`을 확인하고, 실제 파일에서는 분명히 존재하는 토큰(`**` 336개)을 세어 파일이 실제로 읽혔음을 확인했다. 대조군이 통과하지 않으면 그 측정은 무효로 버린다.

**② URL 전수 실측** — 레시피와 판정표는 §5 측정 규율 그대로다.

```sh
curl -sL -o /dev/null -w "%{http_code} r=%{num_redirects} -> %{url_effective}\n" "<URL>"
```

대조군을 먼저 세워 측정이 유효함을 확인했다(이 확인 없이는 「전부 200」을 믿을 수 없다):

| 넣은 URL | 기대 | 실측 |
|---|---|---|
| `sagemaker/latest/dg/zz-bogus-control.html` (없는 슬러그) | `200 r=1` | **`200 r=1`** ✅ |
| `aws.amazon.com/what-is/zz-bogus-control/` (없는 페이지) | `404` | **`404 r=0`** ✅ |
| `AmazonCloudWatch/…/WhatIsCloudWatch.html` (정상) | `200 r=0` | **`200 r=0`** ✅ |

→ **판정 신호는 `num_redirects`**이고, `docs.aws.amazon.com`은 없는 슬러그에도 404를 주지 않는다. 전체 URL로 세고(슬러그로 세면 교체 URL이 옛 URL의 부분 문자열인 경우 거짓 양성), `repost.aws` 403은 봇 체크이므로 **두 번째 방법**(AWS 문서 리더)으로 실재를 확인한다.

**③ 사람 통독** — 556문항을 `지문 + 보기(정답 표시) + 해설 + 오답 근거 + 출처`로 압축 덤프해 **전수 정독**했다. 읽으며 다음 일곱 가지를 표시했다: ⓐ 정답이 둘이거나 없음 ⓑ 참인 보기를 오답으로 둠 ⓒ 수치·상한·기본값 ⓓ 「유일한·항상·전부」 과도한 일반화 ⓔ 서비스 역할 경계(SOA=운영/모니터링, DEA=파이프라인에서 겹치는 자리) ⓕ 귀속 층(공식 서술 ↔ 저작자 추론) ⓖ 닫힌·은퇴 서비스.

**④ 공식 실측** — ①③이 지목한 것만, 공식 문서 본문을 열어 판정한다. **공식이 갈리면 더 구체적인 전용 페이지를 정본으로 삼고, 고를 수 없으면 「단정하지 않는다」가 정답**이며 그 자리는 양쪽 URL을 함께 적는다.

### 0-3. 중복 보고 회피 — 선행 작업을 먼저 읽었다

- `docs/saa-review/2026-10-29-soa-dea-source-url-audit.md`(고유 URL 561개 전수 실측, 리다이렉트 22건 교체) — **거기서 교체한 URL은 보고하지 않는다.** 다만 그 뒤 새로 은퇴했을 수 있으므로 **재측정은 했다**(§3).
- 그 감사 **§4의 「검수자 확인 필요」 1건**(`soa-t1-1-q11` EventBridge)은 2026-11-01에 닫혔음을 실측 확인했다(현재 해설이 "EventBridge는 경보 작업이 아니라 … 이벤트를 내보내는 곳"으로 정정되고 실제 작업 목록에 Lambda가 들어 있다). **같은 계열이 다른 자리에 더 있는지**를 ⓔ 축으로 전수 확인했고 추가 발견은 없다(§5).
- 그 감사 **§2 A7의 「검수자 판단 필요」는 아직 열려 있다** — §4-3에 남겼다.
- 기존 가드 10종(`soa_facts_test` · `soa_question_facts_test` · `soa_v11_topics_test` · `soa_guide_v11_test` · `soa_content_structure_test` · `soa_questions_test` · `dea_questions_test` · `soa_dea_question_propagation_test` · `source_url_retired_test` · `content_format_test`)을 먼저 읽고, **각 제안이 어느 단정과 충돌하는지**를 항목에 붙였다(§2·§3 「가드」 줄).

### 0-4. ⟲ 실행하며 달라진 점

1. **⟲ 작업 디렉터리가 `cd`로 바뀌는 환경이었다.** 첫 `cd` 이후 기준 디렉터리가 이동해 상대경로가 엉뚱한 곳을 가리켰다. 이후 모든 명령에 절대경로를 썼다.
2. **⟲ 「정답 쏠림」을 P1 후보로 올렸다가 내렸다.** SOA가 index 0에 **86.3%**(259/300) 쏠려 있어 F축 중대 결함으로 보였으나, `lib/`를 읽어 **모든 풀이 경로가 보기 순서를 셔플**함을 확인했다(`quiz_page.dart:40` · `review_page.dart:77` · `mock_exam.dart:85`의 `randomOptionOrders`/`applyOptionOrders`). 학습자에게 비노출이므로 **P3(저작 위생)**로 내렸다(§4-1).
3. **⟲ DEA 수치를 의심했다가 내가 틀렸다.** Firehose 기본 버퍼(5 MB/300초)와 간격 범위(0~900초)를 오류 후보로 올렸으나 공식 `BufferingHints`가 `IntervalInSeconds` 기본 **300**, `SizeInMBs` 기본 **5**를 적고 FAQ가 **0~900초**를 적는다. DEA가 정확했다(§5).
4. **⟲ URL 측정 결과의 열 순서를 한 행에서 거꾸로 읽었다.** `security-agent/ → continuum/`을 반대로 읽어 엉뚱한 URL을 찾아 헤맸다(§7).
5. **⟲ 「Regional NAT Gateway」를 SAA 본문에서 보고 그대로 쓰지 않고 독립 검증했다.** `nat-gateway-basics.html`은 아직 영역형만 적어(AWS 내부 불일치) 레포 서술을 근거로 삼을 수 없었기 때문이다. 전용 페이지를 찾아 확정했다(§2-2).
6. **⟲ 범위는 줄이지 않았다.** 556문항 전수 통독과 1,208 URL 전수 실측을 모두 끝냈다. 줄인 것은 **학습문서 본문의 문장 단위 통독**이다(§6).

---

## 1. 집계

### 공통

| | 수 |
|---|---|
| 검토한 학습문서 | **37편** (SOA 20 · DEA 17) · 1.19MB |
| 검토한 문항 | **556개** (SOA 300 · DEA 256) — **전수 통독** |
| 라이브(`verified: true`) | **556 / 556 (100%)** |
| 측정한 고유 URL | **1,208개** (문항 `sources` 561 + 학습문서 647) |
| 대조한 공식 페이지 | **24개**(본문 열어 문장 확인) + 검색 결과 청크 다수 |
| 파서 미지원 표기 `[텍스트](링크)` | **0건** ✅ |
| 파서 미지원 표기 단일 `*이탤릭*` | **0건** ✅ |
| 보기 수 | **4개로 100% 균일**(556/556) ✅ |
| 지문 중복 · 한 문항 내 보기 중복 | **0건** ✅ |

### 발견 건수

| | SOA-C03 | DEA-C01 | 합계 |
|---|---|---|---|
| **P1** 라이브 사실 오류(즉시 수정) | **4** | **0** | **4** |
| **P2** 출처 결함·과도한 일반화 | **6** | **3** | **9** |
| **P3** 보강 후보 | **5** | **1** | **6** |
| 합계 | 15 | 4 | **19** |

### 정답 인덱스 분포

| cert | 0 | 1 | 2 | 3 | 최대 비중 |
|---|---|---|---|---|---|
| SOA | 259 | 30 | 9 | 2 | **86.3%** ⚠️ |
| DEA | 109 | 67 | 52 | 28 | 42.6% ✅ |

→ 런타임 셔플로 학습자에게는 보이지 않는다(§0-4 ⟲2). SOA는 §4-1에 저작 위생 항목으로 남겼다.

### 총평

**DEA-C01의 품질이 눈에 띄게 높다.** 256문항에서 P1이 0건이고, 출처가 서비스 소개 페이지 대신 **사실을 담은 좁은 페이지**(API 참조·고려사항·제한 페이지)를 가리키며, 수치가 공식 문장과 글자 단위로 맞는다. 더 나아가 **AWS 자신의 문서 간 불일치를 그대로 「갈린다」고 적는** 자리가 여럿 있다(`dea-t4-5-q4` "일부 문서는 아직 읽기 목적 공유로만 서술합니다", `dea-t4-4-q7` "문서 간 일수 표현에 차이가 있습니다", `dea-t3-3-q2` "공식 자료 간 서술이 엇갈려 설계 근거로 삼기에 적절하지 않습니다"). 이것은 이 레포가 요구하는 C축 규율을 모범적으로 지킨 것이다.

**SOA-C03의 결함은 한 가지 패턴으로 모인다: SAA에서 이미 고친 계열이 SOA에 적용되지 않았다.** P1 4건 중 3건(DX over VPN · Regional NAT Gateway · Multi-AZ 일반화)이 모두 2026-10~11에 SAA에서 정정되고 전파 가드까지 걸린 계열인데, **SOA·DEA에는 같은 작업이 가지 않았다.** 이것이 가장 쓸모 있는 단일 교훈이다 — 다음에 어느 자격증에서 사실을 정정하면 **그 문구로 레포 전역을 쓸고 가드도 전역으로** 걸어야 한다.

---

## 2. P1 — 라이브 사실 오류 (즉시 수정 대상)

### SOA-C03

#### P1-SOA-1. `soa-t5-2.md` 6개소 + `soa-t5-2-q8` — 「DX over VPN」은 위아래가 거꾸로다 (+ MACsec 누락)

① **위치**
- `flutter_app/assets/content/soa/soa-t5-2.md:156, 161, 234, 262, 263, 299` (6개소)
- `flutter_app/assets/content/soa/soa-t5-2.questions.json:209` (`soa-t5-2-q8` 해설)

② **현재 문구 그대로**

```
soa-t5-2.md:156  - 암호화: **기본 없음**. 전송 암호화가 필요하면 **DX 위에 VPN을 얹음(DX over VPN)**.
soa-t5-2.md:234  - **Direct Connect = 전용 회선, 일관된 저지연, 기본 무암호화.** 암호화 필요 시 **DX over VPN**.
soa-t5-2.md:299  ① **DX over VPN**: Direct Connect 위에 IPsec VPN 터널을 얹어 전송 암호화 요건을 충족합니다(DX는 기본 무암호화).
soa-t5-2-q8 해설  암호화 요건이 있으면 DX 위에 IPsec VPN을 구성(DX over VPN)해야 하며, …
```

③ **왜 틀렸는지** — 두 겹이다.
- **(a) 명칭 역전.** 공식 용어는 **`VPN over Direct Connect`**다. 얹히는 쪽이 VPN이므로 `A over B`에서 A=VPN, B=DX여야 한다. 레포 본문이 "DX **위에** VPN을 얹음"이라고 올바르게 서술하면서 괄호 라벨만 `DX over VPN`으로 거꾸로 달아, **학습자가 외우는 용어가 틀린다.**
- **(b) 선택지 누락.** `:156`이 전송 암호화의 수단을 VPN 하나로 적는데, **질문 자신이 인용하는 출처 페이지**가 **두 가지**를 적는다(Site-to-Site VPN 결합과 MACsec).

④ **공식 URL + 실측 근거**
- `https://docs.aws.amazon.com/vpn/latest/s2svpn/private-ip-dx.html` — "With private IP VPN, you can deploy **IPsec VPN over Direct Connect**, encrypting traffic between your on-premises network and AWS, without the use of public IP addresses…" (`200 r=0` 실측)
- `https://docs.aws.amazon.com/directconnect/latest/UserGuide/encryption-in-transit.html` — **q8의 출처 그 페이지다.** "AWS Direct Connect does not encrypt your traffic that is in transit by default." / "With AWS Direct Connect and AWS Site-to-Site VPN, you can combine … This combination provides an IPsec-encrypted private connection" / "**MAC Security (MACsec)** is an IEEE standard … You can use Direct Connect connections that support MACsec to encrypt your data from your corporate data center to the Direct Connect location."
- **레포 내부 대조**: `saa/saa-t3-8.md:212`는 이미 올바르다 — "암호화: **기본 없음**. 선택지가 둘입니다 — DX 위에 IPsec VPN을 얹는 **VPN over Direct Connect**, 또는 아래의 **MACsec**". `saa-t3-8.questions.json:156`의 `skill` 태그도 `VPN over Direct Connect`다.
- 전수 확인: 레포에서 `DX over VPN`은 **SOA에만 7개소**, `VPN over Direct Connect`는 **SAA에만** 있다.

⑤ **제안 수정안**
- 6개소 + q8 해설의 `DX over VPN` → **`VPN over Direct Connect`**.
- `:156`의 암호화 줄을 SAA 표현처럼 **둘로** 바꾼다: "암호화: **기본 없음**. 선택지가 둘입니다 — DX 위에 IPsec VPN을 얹는 **VPN over Direct Connect**, 또는 **MACsec**(지원 전용 연결에서 데이터센터↔DX 로케이션 구간의 계층 2 암호화)."
- q8은 정답 인덱스를 바꿀 필요가 없다(보기 0이 네 보기 중 유일하게 맞다). 해설의 명칭만 고친다.
- ⚠️ **같은 혼동이 2026-10-29 감사 §2 A6에서 이미 경고된 자리다**("제목만 보고 고르면 반복된다"). 그 경고가 SOA 본문에는 적용되지 않았다.

⚠️ **가드 충돌**: `flutter_app/test/soa_v11_topics_test.dart:371`의 `changed` 맵이 `'soa-t5-2': '2026-10-20'`으로 `lastVerified`를 고정한다. 본문을 고치면 **그 날짜를 함께 올려야** 한다(이 맵은 #313에서 바로 이런 정정을 위해 리터럴 하나 → 문서별 맵으로 바꾼 것이라, 날짜 한 줄 수정이 설계된 경로다). `soa_dea_question_propagation_test.dart`에는 이 문구 규칙이 없으므로 **정정 후 `_nameRules`에 `DX over VPN` 금지 규칙을 추가**해 재유입을 막는 것을 권한다(명칭 오류이므로 오답 보기까지 보는 `_nameRules` 쪽이 맞다).

---

#### P1-SOA-2. `soa-t5-1-q5` — Regional NAT Gateway 때문에 오답 보기 3이 참이 됐다 (정답 둘)

① **위치** `flutter_app/assets/content/soa/soa-t5-1.questions.json:120-132` (`soa-t5-1-q5`)

② **현재 문구 그대로**

```
Q: NAT 게이트웨이에 대한 설명으로 올바른 것은?
  *0) 보안 그룹을 연결할 수 없고 NACL로만 트래픽을 제어한다
   2) 프라이빗 서브넷에 생성해야 한다
   3) VPC 전체가 공유하는 리전 단위 리소스다            ← 오답으로 표시
E: … 또한 퍼블릭 서브넷에 생성하는 AZ 단위 리소스이며, AZ 내에서 이중화됩니다.
W2: NAT 게이트웨이는 퍼블릭 서브넷에 둡니다.
W3: AZ 단위 리소스입니다.
```

③ **왜 틀렸는지** — 2025-11에 추가된 **리전 가용성 모드(Regional NAT Gateway)**는 **VPC 수준에서 동작하고 전 AZ를 단일 ID로 덮으며 퍼블릭 서브넷을 필요로 하지 않는다.** 따라서 보기 3 "VPC 전체가 공유하는 리전 단위 리소스다"는 **현행 공식 문서 기준으로 참**이고, 정답 보기 0도 참이므로 **정답이 둘인 문항**이 된다. 해설의 "퍼블릭 서브넷에 생성하는 AZ 단위 리소스"와 `W3`의 "AZ 단위 리소스입니다"도 **영역형(zonal)에만** 맞는 말이다. 라이브 문항이라 학습자가 지금 이 혼란을 겪는다.

④ **공식 URL + 실측 근거**
- `https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateways-regional.html` — "Regional NAT gateways for automatic multi-AZ expansion": "**Simplified setup** – Use a **single NAT ID across all Availability Zones**…" / "**Enhanced security** – **No public subnets required.** A regional NAT Gateway is a standalone resource with its own route table and you do not need a public subnet in your VPC to host a regional NAT Gateway" / "**Automatic high availability** – Automatically expands and contracts with your workload footprint" / "support up to **32 IP addresses per Availability Zone** (compared to 8 for zonal NAT gateways)"
- `https://aws.amazon.com/blogs/networking-and-content-delivery/introducing-amazon-vpc-regional-nat-gateway/` — "Today, AWS announced **regional availability mode** for NAT Gateways… Your RNAT **operates at the VPC level**, and you do not need to create public subnets to host it."
- ⚠️ **AWS 내부 불일치**: `https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-basics.html`은 아직 "Each NAT gateway is created in a **specific Availability Zone**"만 적고 리전 모드를 언급하지 않는다. §5-5 규율대로 **더 구체적인 전용 페이지(`nat-gateways-regional.html`)를 정본**으로 삼았고, 두 URL을 함께 적는다.
- **레포 내부 대조**: SAA는 이미 고쳐졌다 — `saa/saa-t1-3.questions.json:156`의 지문이 "**영역형(zonal)** NAT 게이트웨이를 배치할 올바른 위치"로 한정하고, 해설이 "2025-11에 추가된 리전 NAT 게이트웨이는 퍼블릭 서브넷이 필요 없고 워크로드가 있는 가용 영역으로 자동 확장·축소되며…"를 병기한다. `saa-t2-4.questions.json:252`도 같다.

⑤ **제안 수정안** — SAA가 쓴 방식을 그대로 옮긴다.
- 지문을 **`영역형(zonal) NAT 게이트웨이`로 한정**한다: "영역형(zonal) NAT 게이트웨이에 대한 설명으로 올바른 것은?"
- 해설에 리전 모드를 **병기**한다: "… 영역형은 퍼블릭 서브넷에 생성하는 AZ 단위 리소스이며 AZ 내에서 이중화됩니다. 2025-11에 추가된 **리전 NAT 게이트웨이**는 VPC 수준 리소스로 퍼블릭 서브넷이 필요 없고 워크로드가 있는 AZ로 자동 확장·축소되며 단일 ID로 전 AZ를 덮습니다(프라이빗 NAT 용도에는 영역형을 씁니다)."
- `W3`을 "**영역형은** AZ 단위 리소스입니다. 리전 단위로 동작하는 것은 리전 NAT 게이트웨이이고 지문은 영역형을 묻습니다."로 바꾼다.
- **정답 인덱스는 그대로 0.** 보기 0("SG 연결 불가, NACL로만 제어")은 두 모드 모두에서 참이다(`nat-gateway-basics.html`: "You can't associate a security group with a NAT gateway").

⚠️ **가드 충돌 없음**: `soa-t5-1`은 `lastVerified` 고정 맵 두 곳 모두에 없고, `soa_question_facts_test.dart`에도 `soa-t5-1` 참조가 0건이다. 자유롭게 고칠 수 있다.
⚠️ **같은 계열이 7개소 더 있다** → P2-SOA-1(별 항목으로 분리했다. 그쪽은 정답을 둘로 만들지 않으므로 P2다).

---

#### P1-SOA-3. `soa-t1-5.md:134` — gp2가 16,000 IOPS에 도달하는 용량이 틀렸다 (3,334 → 5,334 GiB)

① **위치** `flutter_app/assets/content/soa/soa-t1-5.md:134`

② **현재 문구 그대로**

```
- **gp2 = 1GB당 3 IOPS**(용량에 비례). 작은 볼륨은 **버스트 버킷**으로 일시적으로 **최대 3,000 IOPS**까지
  끌어올릴 수 있고, 약 1,000 GB(≈3,334 GB에서 16,000 IOPS 상한) 이상부터 버스트 없이도 높은 IOPS를
  갖습니다. 버스트 크레딧이 소진되면 베이스라인(3 IOPS/GB)으로 제한됩니다.
```

③ **왜 틀렸는지** — `3,334 GB × 3 IOPS/GiB = 10,002 IOPS`로 16,000에 한참 못 미친다. 산술이 자기 모순이다. 공식 수치는 **5,334 GiB**다. 라이브 학습문서의 수치 오류이고, 문항이 이 값을 묻지는 않지만 학습자가 그대로 외운다.

④ **공식 URL + 실측 근거**
- `https://docs.aws.amazon.com/ebs/latest/userguide/general-purpose.html` (`200 r=0` 실측) — gp2 IOPS performance: "Baseline IOPS performance scales linearly between a minimum of 100 and a maximum of 16,000 at a rate of 3 IOPS per GiB of volume size." / "Volumes larger than 33.33 GiB are provisioned with 3 IOPS per GiB of volume size **up to the maximum of 16,000 IOPS, which is reached at 5,334 GiB (3 X 5,334)**." / "**Volumes 5,334 GiB and larger are provisioned with 16,000 IOPS.**"
- 같은 줄의 나머지는 **옳다**: "gp2 volumes smaller than 1 TiB (and that are provisioned with less than 3,000 IOPS) can **burst to 3,000 IOPS**" → "약 1,000 GB 이상부터 버스트 없이도"가 맞고, "크레딧 소진 시 베이스라인(3 IOPS/GB)"도 맞다.

⑤ **제안 수정안** — 괄호 안 수치만 고친다.

```
… 약 1,000 GB(**≈5,334 GiB에서 16,000 IOPS 상한**) 이상부터 버스트 없이도 높은 IOPS를 갖습니다.
```

⚠️ **가드 충돌**: `soa-t1-5`는 **두 곳**이 `lastVerified`를 고정한다 — `soa_facts_test.dart:151` (`'soa-t1-5': '2026-10-20'`)과 `soa_v11_topics_test.dart:364` (같은 값). 본문을 고치면 **두 파일의 날짜를 함께** 올려야 한다. (`soa_facts_test.dart:145`의 주석이 "문서별 기대값을 명시한다(느슨한 비교가 아니다)"로 이 설계를 적어 두었다.)

---

#### P1-SOA-4. `soa-t1-5-q12` — Multi-AZ 무수식 일반화로 오답 보기 3이 참이 됐다 (정답 둘)

① **위치**
- `flutter_app/assets/content/soa/soa-t1-5.questions.json:311-321` (`soa-t1-5-q12`) ← **정답이 둘이 되는 자리**
- 같은 파일 `:285, 292` (`soa-t1-5-q11` 보기 1 + `W1`) ← 참인 보기를 오답으로 둠
- `flutter_app/assets/content/soa/soa-t1-5.md:160`

② **현재 문구 그대로**

```
q12  Q: RDS 읽기 전용 복제본과 Multi-AZ 배포의 차이를 가장 정확히 설명한 것은?
     *0) 복제본은 읽기 확장(비동기 복제), Multi-AZ는 고가용성·자동 장애 조치(동기 복제 대기본)
      3) Multi-AZ 대기본은 읽기 트래픽을 분산한다                ← 오답으로 표시
     W3: Multi-AZ 대기본은 일반 읽기 트래픽을 받지 않습니다.

q11   1) Multi-AZ 배포로 전환해 대기본에서 읽게 한다              ← 오답으로 표시
     W1: Multi-AZ의 대기본은 고가용성용이며 일반 읽기 트래픽을 처리하지 않습니다.

t1-5.md:160  - **읽기 확장 ≠ 고가용성.** 읽기 복제본은 읽기 성능용입니다. **자동 장애 조치(HA)**는
             **Multi-AZ 배포**의 역할입니다(동기 복제 대기본). 둘을 혼동하지 마세요.
```

③ **왜 틀렸는지** — 공식 문서는 Multi-AZ **배포**를 두 유형으로 가른다. **Multi-AZ DB 클러스터 배포**는 읽기 가능한 리더 두 개를 두고 **반동기(semisynchronous)** 복제를 쓰며 **리더가 읽기 트래픽을 처리한다.** 따라서 수식 없는 "Multi-AZ 배포"로는:
- q12 보기 3 "Multi-AZ 대기본은 읽기 트래픽을 분산한다" → **DB 클러스터 배포에서 참** ⇒ 정답이 둘
- q12 정답 보기 0의 "동기 복제" → DB 클러스터에서는 **반동기**
- q11 보기 1 "Multi-AZ 배포로 전환해 대기본에서 읽게 한다" → **DB 클러스터로 전환하면 실제로 가능** ⇒ 참인 보기를 오답으로 둠

⚠️ **그런데 같은 레포 안에서 `soa-t2-2`는 이것을 올바르게 처리한다** — E축 내부 불일치다. `soa-t2-2.md:109`가 "Multi-AZ DB **클러스터** 배포(2개의 읽기 가능 스탠바이)는 예외적으로 스탠바이가 읽기를 제공하지만, 전통적 Multi-AZ **인스턴스** 배포의 단일 스탠바이는 읽기 불가입니다. 시험 기본값은 후자입니다."로 분기를 명시하고, `soa-t2-2-q1`의 지문도 "RDS Multi-AZ **인스턴스 배포**에서"로 한정한다. **즉 저작 규율은 이미 있고 t1-5에만 적용되지 않았다.**

④ **공식 URL + 실측 근거**
- `https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html` (`200 r=0` 실측) — "Multi-AZ deployments can have one standby or two standby DB instances. When the deployment has one standby DB instance, it's called a *Multi-AZ DB instance deployment*. A Multi-AZ DB instance deployment has one standby DB instance that provides failover support, but **doesn't serve read traffic**. When the deployment has two standby DB instances, it's called a *Multi-AZ DB cluster deployment*. A Multi-AZ DB cluster deployment has standby DB instances that provide failover support and **can also serve read traffic**."
- `https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/multi-az-db-clusters-concepts.html` — "A *Multi-AZ DB cluster deployment* is a **semisynchronous**, high availability deployment mode of Amazon RDS with **two readable replica DB instances**." / "Reader DB instances act as automatic failover targets and **also serve read traffic to increase application read throughput**."
- **레포 내부 대조 — SAA는 이미 고쳐졌다**: `saa/saa-t2-4.questions.json:84`의 지문이 "RDS **Multi-AZ DB 인스턴스 배포(스탠바이 1개)**에서 Primary와 Standby 사이의 복제 방식과 그 이유로 옳은 것은?"이고, `:92` 해설이 "참고로 Multi-AZ DB 클러스터 배포는 다른 배포 유형으로, 리더 두 개를 두고 **반동기(semisynchronous)** 복제를 쓰며 그 리더가 읽기도 처리합니다."를 병기한다. `:132`도 같은 방식이다.

⑤ **제안 수정안** — SAA·`soa-t2-2`가 쓰는 방식으로 통일한다.
- **q12**: 지문을 "RDS 읽기 전용 복제본과 **Multi-AZ DB 인스턴스 배포(스탠바이 1개)**의 차이를…"로 한정. 정답 보기 0의 "(동기 복제 대기본)"은 인스턴스 배포 한정이므로 그대로 두되, 해설에 클러스터 배포 분기를 병기: "… Multi-AZ **DB 클러스터** 배포는 다른 배포 유형으로, 리더 두 개를 두고 **반동기** 복제를 쓰며 그 리더가 읽기도 처리합니다." `W3`을 "**Multi-AZ DB 인스턴스 배포의** 대기본은 일반 읽기 트래픽을 받지 않습니다. 읽기까지 받는 것은 Multi-AZ DB 클러스터 배포의 리더이고 지문은 스탠바이 1개 배포를 묻습니다."로.
- **q11**: 보기 1을 "Multi-AZ **DB 인스턴스 배포**로 전환해 대기본에서 읽게 한다"로 한정하고 `W1`도 같이 한정 + 클러스터 분기 병기.
- **`t1-5.md:160`**: "**자동 장애 조치(HA)**는 **Multi-AZ 배포**의 역할입니다(동기 복제 대기본)" → "**Multi-AZ DB 인스턴스 배포**의 역할입니다(동기 복제 스탠바이 1개). 읽기 가능한 리더 두 개를 두는 **Multi-AZ DB 클러스터 배포**는 별도 옵션으로 반동기 복제를 쓰고 리더가 읽기도 처리합니다 — `soa-t2-2` §2 참고."
- **정답 인덱스 변경 없음**(q11=0, q12=0).

⚠️ **가드 충돌**: `soa-t1-5`의 `lastVerified`가 두 곳에 고정돼 있다(P1-SOA-3과 같은 자리). **P1-SOA-3과 한 PR로 묶으면 날짜 수정이 한 번**이다.
⚠️ **같은 계열 3건이 더 있다**(정답을 둘로 만들지는 않음) → P2-SOA-2.

### DEA-C01

**P1 없음.** 256문항 전수 통독에서 정답이 둘이거나 없는 문항, 참인 보기를 오답으로 둔 문항을 **찾지 못했다.** 수치 단정 14건을 공식 문서로 표집 확인했고 모두 일치했다(§5).

---

## 3. P2 — 출처 결함 · 과도한 일반화

### 3-1. SOA-C03

#### P2-SOA-1. NAT 게이트웨이 「AZ 단위 리소스」 단정 11개소 (P1-SOA-2의 잔여)

① **위치** — 전수 `grep` 결과
- `soa-t5-1.md:154, 212, 232` (3개소)
- `soa-t2-2.md:39, 147, 153, 160, 191, 226, 234, 247, 279` (9개소)
- `soa-t2-2.questions.json:186` (`soa-t2-2-q7` 해설) · `:213` (`soa-t2-2-q8` 해설)
- `soa-t5-1.questions.json:70` (`soa-t5-1-q6` 해설)

② **현재 문구 그대로 (대표)**

```
soa-t5-1.md:154  > **운영 핵심:** NAT Gateway는 **단일 AZ 리소스**입니다. AZ 장애에도 견디려면 **AZ마다
                  NAT Gateway를 두고**, 각 AZ의 프라이빗 라우팅 테이블이 같은 AZ의 NAT를 가리키도록 구성합니다.
soa-t2-2.md:147  > NAT 게이트웨이는 **AZ 단위 리소스**입니다. 특정 AZ의 퍼블릭 서브넷에 배치됩니다.
soa-t2-2.md:160  > 🧠 원리: 왜 NAT 게이트웨이는 VPC 전체가 공유하는 방식이 아니라 AZ 단위 리소스로 배치될까요?
soa-t2-2-q7 해설  NAT 게이트웨이는 AZ 단위 리소스입니다. …
```

③ **왜 틀렸는지** — P1-SOA-2과 같은 근거다. 영역형에만 맞는 말을 NAT 게이트웨이 전체의 성질로 단정한다. 특히 `soa-t2-2.md:160`의 「🧠 원리」는 "**왜** VPC 전체가 공유하는 방식이 **아닌가**"를 설명하므로, 리전 모드가 바로 그 방식을 제공하는 현재로서는 원리 설명 자체가 낡았다. 다만 이 자리들은 **정답을 둘로 만들지 않는다**(AZ별 배치가 영역형의 올바른 운영 지침이라는 결론은 그대로 유효). 그래서 P2다.

④ **공식 URL + 실측 근거** — P1-SOA-2과 동일: `https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateways-regional.html` ("No public subnets required" · "single NAT ID across all Availability Zones" · "Automatically expands and contracts with your workload footprint"). 영역형 서술의 정본은 `https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-basics.html` ("Each NAT gateway is created in a specific Availability Zone and implemented with redundancy in that zone. … To improve resiliency, create a NAT gateway in each Availability Zone").

⑤ **제안 수정안** — 전부를 고칠 필요는 없다. **각 문서에서 NAT를 처음 정의하는 자리 2개소만 분기**를 넣고, 나머지는 영역형 문맥임이 드러나므로 둔다.
- `soa-t5-1.md:154`와 `soa-t2-2.md:147`에 한 줄 추가: "⚠️ 이 성질은 **영역형(zonal)** NAT 게이트웨이의 것입니다. 2025-11에 추가된 **리전 NAT 게이트웨이**는 VPC 수준 리소스로 퍼블릭 서브넷이 필요 없고 워크로드가 있는 AZ로 자동 확장·축소되며 단일 ID로 전 AZ를 덮습니다."
- `soa-t2-2.md:160`의 「🧠 원리」 질문을 "왜 **영역형** NAT 게이트웨이는 AZ 단위로 배치될까요?"로 한정.
- 문항 해설 3건(`t2-2-q7`·`q8`·`t5-1-q6`)은 지문이 이미 "AZ마다 NAT를 두는" 영역형 시나리오이므로 **해설 첫 단어만** "**영역형** NAT 게이트웨이는 AZ 단위 리소스입니다"로.

⚠️ **가드 충돌 없음**: `soa-t5-1`·`soa-t2-2` 모두 `lastVerified` 고정 맵과 `soa_question_facts_test` 참조가 **0건**이다.

---

#### P2-SOA-2. Multi-AZ 무수식 일반화 3건 (P1-SOA-4의 잔여)

① **위치**
- `soa-t2-2.questions.json` → `soa-t2-2-q4` (지문·해설·W1~W3) · `soa-t2-2-q14` (해설 "동기 복제이므로 데이터 유실이 없고")
- `soa-t2-4.questions.json` → `soa-t2-4-q10` `W2` ("Multi-AZ는 동기 복제라 자동 장애 조치가 가능합니다")

② **현재 문구 그대로**

```
q4  Q: RDS Multi-AZ와 읽기 전용 복제본의 복제 방식을 올바르게 짝지은 것은?
    *0) Multi-AZ = 동기, 읽기 복제본 = 비동기
    E: Multi-AZ는 동기 복제로 쓰기가 양쪽에 커밋돼야 응답하므로 데이터 유실이 없고, …
q14 E: … 동기 복제이므로 데이터 유실이 없고, 엔드포인트 이름도 그대로 유지됩니다.
t2-4-q10 W2: Multi-AZ는 동기 복제라 자동 장애 조치가 가능합니다.
```

③ **왜 틀렸는지** — Multi-AZ **DB 클러스터** 배포는 **반동기**다. 세 자리 모두 수식 없는 "Multi-AZ"에 "동기"를 붙인다. **다만 정답을 둘로 만들지는 않는다** — q4의 네 보기 중 0 외에 참이 되는 것이 없고(클러스터도 "비동기"는 아니다), q14·q10은 오답 근거 문장이다. 그래서 P2다. 같은 파일 `soa-t2-2-q1`이 "**인스턴스 배포**"로 올바르게 한정하는 것과 **한 파일 안에서 어긋난다**(E축).

④ **공식 URL + 실측 근거** — P1-SOA-4과 동일(`Concepts.MultiAZ.html` · `multi-az-db-clusters-concepts.html`의 "semisynchronous").

⑤ **제안 수정안** — q4 지문을 "RDS **Multi-AZ DB 인스턴스 배포**와 읽기 전용 복제본의 복제 방식을…"로 한정하고 해설에 "Multi-AZ **DB 클러스터** 배포는 반동기입니다" 한 줄 병기. q14·q10 `W2`는 "**Multi-AZ DB 인스턴스 배포는** 동기 복제라…"로 수식만 추가. **정답 인덱스 변경 없음.**

⚠️ **가드 충돌 없음**: `soa-t2-2`는 고정 맵에 없다. `soa-t2-4`는 `soa_facts_test.dart:152`가 `lastVerified: 2026-10-20`을 고정하지만 **문항 파일은 그 단정 대상이 아니므로** q10만 고치면 충돌하지 않는다.

---

#### P2-SOA-3. `soa-t2-1.md:173` — ELB 상태 확인이 「유일한 경로」는 거짓이다

① **위치** `flutter_app/assets/content/soa/soa-t2-1.md:173`

② **현재 문구 그대로**

```
> ELB 상태 확인은 대상 그룹이 지정한 경로로 HTTP/TCP 요청을 직접 보내 응답을 검증하므로,
  앱 계층 장애를 ASG가 인지해 인스턴스를 교체하게 만드는 **유일한 경로**입니다.
```

③ **왜 틀렸는지** — ASG는 비정상 통지를 **다섯 가지 소스**에서 받고, 그중 **사용자 정의 상태 확인**(`SetInstanceHealth`)이 바로 앱 계층 신호를 ASG에 전달하라고 제공되는 수단이다. 공식 문서에는 「애플리케이션 상태 확인을 Auto Scaling 그룹과 함께 사용」 절도 따로 있다. 「유일한」이 거짓이다.

④ **공식 URL + 실측 근거**
- `https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-health-checks.html` (`200 r=0` 실측) — "It can receive notifications from various sources when an instance becomes unhealthy and must be replaced. These sources include the following: **Amazon EC2 / Elastic Load Balancing / VPC Lattice / Amazon EBS / Custom health checks that you define**" / 목차에 "Set up a custom health check for your Auto Scaling group" · "**Use application status checks with an Auto Scaling group**"

⑤ **제안 수정안**

```
> ELB 상태 확인은 대상 그룹이 지정한 경로로 HTTP/TCP 요청을 직접 보내 응답을 검증하므로,
  앱 계층 장애를 ASG가 인지하게 만드는 **가장 일반적인 경로**입니다. 공식 문서는 ASG가
  비정상 통지를 받는 소스로 **EC2 · Elastic Load Balancing · VPC Lattice · EBS ·
  사용자 정의 상태 확인** 다섯 가지를 들며, ELB를 쓸 수 없는 구성에서는
  사용자 정의 상태 확인(`SetInstanceHealth`)으로 앱 신호를 전달할 수 있습니다.
```

- 같은 계열로 `soa-t2-1-q10` 해설("앱 계층 장애를 ASG가 인지하려면 ELB 상태 확인을 활성화해 … 써야 합니다")도 **"해야 합니다" → "쓰는 것이 표준입니다"** 정도로 누그러뜨리는 것을 권한다. 다만 그 문항은 지문이 ELB가 이미 있는 시나리오라 **정답은 그대로 유효**하고 급하지 않다.

⚠️ **가드 충돌 없음**: `soa-t2-1`은 고정 맵·`soa_question_facts_test` 참조 모두 0건.

---

#### P2-SOA-4. `soa-t4-3.md:246` — RDS 암호화 전환이 「유일한 방법」은 거짓이다

① **위치** `flutter_app/assets/content/soa/soa-t4-3.md:246` (관련: `:151`, `:155`, `:226`, `:245`, `soa-t4-3-q7` 해설)

② **현재 문구 그대로**

```
soa-t4-3.md:245  4. **"운영 중인 RDS 인스턴스를 콘솔에서 바로 암호화로 전환한다."** → 불가능.
                 **스냅샷 생성 → 암호화 복사 → 복원** 절차를 거쳐야 합니다.
soa-t4-3.md:246    (원리: §4 — RDS 암호화는 스토리지 볼륨 초기화 시점에 결정되므로 운영 중 전환 경로가 없고
                 새 볼륨으로의 이전이 **유일한 방법**이다.)
```

③ **왜 틀렸는지** — 「콘솔 체크박스로는 못 바꾼다」는 **맞다**. 그러나 **「스냅샷 경유가 유일한 절차」는 아니다.** 공식 Blue/Green 배포가 green 리소스에 `TargetKmsKeyId`를 지정하는 경로를 제공하고, 그 용례를 **"The blue resource is unencrypted and you want to encrypt the green resource."**로 명시한다. 읽기 복제본을 경유하는 최소 다운타임 절차도 별도로 안내된다. 「유일한」이 거짓이다.

④ **공식 URL + 실측 근거**
- `https://docs.aws.amazon.com/aws-sdk-php/v3/api/api-rds-2014-10-31.html` (`TargetResourceConfiguration`) — "**TargetKmsKeyId** … Specify this setting in either of the following cases: • You want the green resource to use a different KMS key than the blue resource. • **The blue resource is unencrypted and you want to encrypt the green resource.** … For RDS, encryption applies at the DB instance level."
- `https://repost.aws/knowledge-center/rds-encrypt-instance-mysql-mariadb` — "To encrypt an unencrypted DB instance with minimal downtime, complete the following steps: 1. Encrypt an unencrypted snapshot that you take from an **unencrypted read replica** of the DB instance. …" (403은 봇 체크이며 AWS 문서 리더로 본문 확인)
- 제약 자체도 공식에 있다: "You can't modify an existing unencrypted Amazon RDS DB instance to encrypt the instance."
- **레포 내부 대조**: SAA는 2026-10-28에 이 계열을 이미 고쳤다(`saa-t1-5.md`와 q14 양쪽, 메모리 `saa` 트랙 B조(2) 기록).

⑤ **제안 수정안**

```
  (원리: §4 — RDS 암호화는 스토리지 볼륨 초기화 시점에 결정되므로 **기존 인스턴스를 제자리에서
  전환할 수는 없고** 새로 암호화된 볼륨으로 데이터를 옮기는 경로를 거쳐야 한다. 가장 기본적인
  절차가 스냅샷 → 암호화 복사 → 복원이고, **Blue/Green 배포에서 green 리소스에
  `TargetKmsKeyId`를 지정하는 경로**도 공식 지원된다.)
```

- `:151`의 표 칸("**생성 후 직접 전환 불가** → 스냅샷 생성 → 암호화 복사 → 복원")은 「직접 전환 불가」가 맞으므로 **그대로 두어도 된다.** 고쳐야 하는 것은 `:246`의 「유일한 방법」과 `:155`의 "결국 … 동일한 경로입니다"다.
- `soa-t4-3-q7`은 **정답(보기 0)이 네 보기 중 유일하게 맞으므로 인덱스 불변**이고, 해설의 "절차가 필요합니다" → "절차가 기본입니다(Blue/Green 배포로 `TargetKmsKeyId`를 지정하는 경로도 있습니다)" 정도로 완화.

⚠️ **가드 충돌**: `soa_facts_test.dart:154`가 `'soa-t4-3': '2026-10-19'`로 `lastVerified`를 고정한다. 본문 수정 시 그 날짜를 올려야 한다. 또 `soa_facts_test.dart:166-167`이 `soa-t4-3`에 `key-policy-overview`·`certificate-manager/pricing`이 실려 있는지 단정하므로 **그 두 출처를 지우지 않도록** 주의한다.

---

#### P2-SOA-5. 학습문서 4편의 죽은·이동 URL 4건 (2026-10-29 감사 이후)

① **위치 + ② 현재 문구 + ④ 실측**

| # | 파일:행 | 현재 URL | 실측 | 판정 |
|---|---|---|---|---|
| a | `soa-t1-4.md:18` (프런트매터 `url:`) · `:314` (참고자료 4) | `AWSEC2/latest/UserGuide/ec2-instance-recovery.html` | `200 r=1 → AWSEC2/latest/UserGuide/` | **페이지 소멸** |
| b | `soa-t2-3.md:16` · `:272` (참고자료 3) | `AWSEC2/latest/UserGuide/EBSSnapshots.html` | `200 r=1 → ebs/latest/userguide/ebs-snapshots.html` | 이름·가이드 이동 |
| c | `soa-t2-3.md:18` · `:273` (참고자료 4) | `AWSEC2/latest/UserGuide/snapshot-lifecycle.html` | `200 r=1 → ebs/latest/userguide/snapshot-lifecycle.html` | 이름·가이드 이동 |
| d | `soa-t3-2.md:22` · `:266` (참고자료 6) | `systems-manager/latest/userguide/sysman-patch-patchgroups.html` | `200 r=1 → …/patch-manager-patch-groups.html` | 이름 변경 |

③ **왜 문제인지** — 라이브 학습문서의 「📌 출처」와 프런트매터가 가리키는 페이지다. (a)는 인덱스로 보내므로 **소멸**이고, AWS 문서 리더로 열면 `concepts.html`("What is Amazon EC2?")로 리다이렉트되는데 **그 페이지에는 인스턴스 자동 복구 내용이 없다.** 학습자가 출처를 눌러도 인용된 사실을 찾을 수 없다.

⚠️ **같은 Task의 문항은 이미 올바른 URL을 쓴다 — 내부 불일치다.** `soa-t1-4-q7`·`q8`·`q9`의 출처는 `AWSEC2/latest/UserGuide/ec2-instance-recover.html`(**`recovery` 아닌 `recover`**, `200 r=0`)이고, `soa-t2-3-q5`·`q6`은 `ebs/latest/userguide/ebs-snapshots.html`·`snapshot-lifecycle.html`(`200 r=0`)이다. **문항 가드는 `.md`를 보지 않아서** md만 낡은 채 남았다(2026-10-28 `saa-t4-3.md` 재발 방지 교훈이 적용되지 않은 자리).

⑤ **제안 수정안 (교체 정본을 실측했다)**

| # | 교체 URL | 실측 | 그 페이지가 적는 문장 |
|---|---|---|---|
| a | `https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-recover.html` | `200 r=0` | "**Automatic instance recovery** … there are two mechanisms that can automatically restore instance availability—**simplified automatic recovery** and **Amazon CloudWatch action based recovery**." |
| b | `https://docs.aws.amazon.com/ebs/latest/userguide/ebs-snapshots.html` | `200 r=0` | (301 대상이자 문항이 이미 쓰는 정본) |
| c | `https://docs.aws.amazon.com/ebs/latest/userguide/snapshot-lifecycle.html` | `200 r=0` | (301 대상이자 문항이 이미 쓰는 정본) |
| d | `https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager-patch-groups.html` | `200 r=0` | (301 대상) |

⚠️ **(a)는 보강 기회가 함께 있다.** `ec2-instance-recover.html`이 적는 **「두 메커니즘」**(기본으로 켜지는 *단순 자동 복구* + 선택 구성인 *CloudWatch 작업 기반 복구*)이 `soa-t1-4.md`와 문항에 없다. 현재 콘텐츠는 CloudWatch 경보 기반 복구만 다룬다. 출처를 고치면서 한 줄 추가를 권한다 → P3-SOA-3.
⚠️ **가드**: `source_url_retired_test.dart`의 `retiredUrls`에 이 4건을 **추가**하고(지금은 없다 — 가드는 이미 아는 것만 안다) 교체 정본 실재를 쌍으로 고정하는 것이 그 파일의 운영 규약이다. `soa-t1-4`는 `soa_v11_topics_test.dart:366`이, `soa-t2-3`·`soa-t3-2`는 아무 가드도 `lastVerified`를 고정하지 않는다.

> **「2026-10-29 감사 이후 새로 죽었나」에 대한 정직한 답**: 그 감사는 `assets/content/**` 전수를 훑어 md 3개소(`soa-t1-1.md`·`soa-t3-1.md`)를 찾았다고 적는다. 그 기록이 맞다면 이 4건은 **그 뒤 새로 은퇴**한 것이다. 다만 나는 2026-10-29 시점의 상태를 직접 재지 못했으므로 **「새로 은퇴」와 「그 감사의 md 스윕이 놓쳤다」를 구분할 수 없다.** 어느 쪽이든 **지금 죽어 있다**는 것이 실측이다.

---

#### P2-SOA-6. Amazon Data Firehose 구식 명칭 3개소 (같은 레포 안에서 어긋난다)

① **위치** `soa-t1-2.md:152` · `soa-t1-2.md:329` · `soa-t5-4.md:91`

② **현재 문구 그대로**

```
soa-t1-2.md:152  | **Kinesis Data Firehose** | S3·OpenSearch·Redshift 등으로 거의 실시간 적재(버퍼링·변환) |
soa-t1-2.md:329  … **Kinesis Data Firehose**를 거쳐 **S3**로 적재해 저비용 장기 보관을 구성합니다.
soa-t5-4.md:91   | **Kinesis Data Firehose** | 스트리밍 파이프라인으로 전달 |
```

③ **왜 문제인지** — 공식 현행 명칭은 **Amazon Data Firehose**다(개명). ⚠️ **같은 Task의 문항이 신명칭을 쓴다 — E축 내부 불일치다**: `soa-t5-4-q3`의 정답 보기가 "CloudWatch Logs · Amazon S3 · **Amazon Data Firehose**"이고 해설도 그렇다. 즉 `soa-t5-4.md:91`만 구명칭이다. DEA는 이 함정을 명시적으로 다룬다(`dea-t1-1.md:197` "개명 함정: **Kinesis Data Firehose → Amazon Data Firehose**", `dea-t4-4.md:230` "**같은 서비스의 개명**입니다") — **SOA에만 그 처리가 없다.**

④ **공식 URL + 실측 근거** — `https://docs.aws.amazon.com/firehose/latest/dev/what-is-this-service.html` (`200 r=0`): 페이지 제목이 "**What is Amazon Data Firehose?**"이고 본문이 "Amazon Data Firehose is a fully managed service for delivering real-time streaming data to destinations such as Amazon S3, Amazon Redshift, Amazon OpenSearch Service, …"

⑤ **제안 수정안** — 3개소를 **`Amazon Data Firehose`**로 바꾸고, SOA 학습문서에 개명 주석을 한 번 남긴다(DEA가 하는 방식): "📌 **이전 이름은 Amazon Kinesis Data Firehose**입니다(개명)."
⚠️ **가드**: `soa-t1-2`는 `soa_v11_topics_test.dart:365`가, `soa-t5-4`는 `soa_facts_test.dart:155`가 `lastVerified`를 고정한다. 또 `soa_facts_test.dart:164-165`가 `soa-t5-4`에 `flow-log-records`·`flow-logs-limitations`가 실려 있는지 단정하므로 그 출처를 지우지 않는다.

### 3-2. DEA-C01

#### P2-DEA-1. `dea-t1-1-q7` — EFO 소비자 한도는 「샤드당」이 아니라 「데이터 스트림당」이다

① **위치** `flutter_app/assets/content/dea/dea-t1-1.questions.json` (`dea-t1-1-q7` 해설)

② **현재 문구 그대로**

```
E: Kinesis Data Streams for DynamoDB는 테이블 변경을 KDS로 복제하므로 보존을 최대 1년까지 늘릴 수 있고,
   **EFO 소비자를 샤드당 최대 20개까지** 붙여 KCL·Managed Service for Apache Flink·Firehose 등
   Kinesis 생태계를 활용할 수 있습니다.
```

③ **왜 틀렸는지** — 20은 **데이터 스트림당** 등록 소비자 수 한도이고, **샤드당**이 아니다. 단위를 잘못 적으면 샤드 10개 스트림에서 200개를 붙일 수 있다는 오해가 생긴다. 또 **On-demand Advantage 모드에서는 50**이어서 20이 유일한 값도 아니다. (이 레포가 SAA에서 겪은 「FIFO 300 TPS는 파티션당이 아니라 각 API 작업당」과 같은 계열의 단위 오류다.)
⚠️ **같은 파일의 `dea-t1-1-q2`는 올바르다** — "EFO를 등록하면 **소비자마다 샤드당 전용 2 MB/s**를 받고"는 정확하다(**처리량**은 소비자×샤드 단위). q7이 처리량의 「샤드당」을 소비자 **수**에 옮겨 붙인 것으로 보인다.

④ **공식 URL + 실측 근거**
- `https://docs.aws.amazon.com/streams/latest/dev/service-sizes-and-limits.html` (`200 r=0` 실측) — 쿼터 표의 행 이름이 "**Number of registered consumers per data stream**"이고 값이 "With Kinesis On-demand Advantage mode, you can create up to **50** registered consumers (Enhanced Fan-out). With Kinesis On-Demand Standard and Kinesis Provisioned modes, you can create up to **20** registered consumers (Enhanced Fan-out Limit) **for each data stream**."

⑤ **제안 수정안**

```
E: … 보존을 최대 1년까지 늘릴 수 있고, **EFO 소비자를 데이터 스트림당 최대 20개**
   (On-demand Advantage 모드는 50개)까지 등록해 소비자마다 **샤드당 전용 2 MB/s**로
   KCL·Managed Service for Apache Flink·Firehose 등 Kinesis 생태계를 활용할 수 있습니다.
```

- **정답 인덱스 불변**(1). 해설의 단위만 고친다. `W0`("DynamoDB Streams는 보존이 24시간이고 샤드당 읽기 프로세스를 2개 이하로 두도록 권장")은 **DynamoDB Streams 쪽 권고로 실제 「샤드당」이 맞으므로 건드리지 않는다.**

⚠️ **가드 충돌 없음**: `dea_questions_test.dart`는 구조·밀도 가드이고 이 문구를 고정하지 않는다. `soa_dea_question_propagation_test.dart`의 `_factRules`는 **SOA md 금지 문장에서 온 항목만** 담는 계약이므로(DEA에는 md 사실 가드가 없어 전파할 금지 문장이 없다) 여기에 넣지 않는 것이 그 파일의 설계에 맞다.

---

#### P2-DEA-2. `dea-t2-1.md` 2개소 + `dea-t2-1-q6 W3` + 출처 제목 — Multi-AZ standby 무수식 일반화

① **위치**
- `flutter_app/assets/content/dea/dea-t2-1.md:169` · `:282`
- `flutter_app/assets/content/dea/dea-t2-1.questions.json` → `dea-t2-1-q6` `W3`
- 같은 파일 `:189` (출처 **제목** 문자열)

② **현재 문구 그대로**

```
dea-t2-1.md:169  - **RDS 읽기 복제본 vs Multi-AZ** — 읽기 복제본은 **비동기 복제로 읽기 트래픽을 분산**하고,
                 **Multi-AZ standby는 동기 복제이지만 읽기 트래픽을 받지 못합니다.**
dea-t2-1.md:282  13. **"Multi-AZ standby로 읽기를 분산한다."** → ❌. **standby는 읽기 트래픽을 받지 못합니다.**
q6 W3           Amazon RDS의 Multi-AZ 대기 복제본은 읽기 트래픽을 처리하지 않습니다. …
sources[].title "Working with DB instance read replicas (Amazon RDS) — Multi-AZ standby는 읽기 트래픽을 처리하지 않음"
```

③ **왜 틀렸는지** — P1-SOA-4과 같은 근거다. Multi-AZ **DB 클러스터** 배포의 리더는 읽기를 처리하고 복제는 **반동기**다. **정답은 둘이 되지 않는다** — q6은 Aurora I/O-Optimized를 묻고 `W3`은 보기 3을 떨어뜨리는 근거이며, 보기 3이 "**Multi-AZ 대기 복제본**을 추가해 읽기 트래픽을 보낸다"로 Aurora 문맥에 섞여 있어 어차피 오답이다. 그래서 P2다.
⚠️ **⓹ SOA와 DEA가 같은 서비스를 같은 방식으로 틀린 자리다** — 두 자격증을 한 세션이 맡은 이유가 여기서 드러난다. 한 번에 고치면 두 트랙이 동시에 정리되고, SOA의 `soa-t2-2.md:109`가 이미 가진 올바른 분기 문장을 그대로 재사용할 수 있다.

④ **공식 URL + 실측 근거** — P1-SOA-4과 동일(`Concepts.MultiAZ.html`의 "can also serve read traffic" · `multi-az-db-clusters-concepts.html`의 "semisynchronous").

⑤ **제안 수정안** — md 2개소와 `W3`에 수식을 넣는다: "**Multi-AZ DB 인스턴스 배포의** standby는 동기 복제이지만 읽기 트래픽을 받지 못합니다. 읽기 가능한 리더 두 개를 두는 **Multi-AZ DB 클러스터 배포**는 별도 배포 유형으로 반동기 복제를 쓰고 리더가 읽기도 처리합니다." 출처 **제목** 문자열도 같이 한정한다(제목은 사실 서술이므로 틀리면 안 된다 — 2026-10-29 감사가 t4-5에서 "M2 메모가 출처 제목에도 숨는다"로 배운 자리와 같은 계열이다).
⚠️ **가드 충돌 없음**: DEA에는 md 사실 가드가 없다.

---

#### P2-DEA-3. 죽은·이동 URL 3건 (문항 2 + 학습문서 1)

| # | 위치 | 현재 URL | 실측 | 교체 정본(실측) |
|---|---|---|---|---|
| a | `dea-t1-2.questions.json:226` (`dea-t1-2-q7` 둘째 출처) · `dea-t1-2.md:278` (참고자료 16) | `whitepapers/latest/big-data-analytics-options/amazon-athena.html` | `200 r=1 → athena/latest/ug/what-is.html` | `https://docs.aws.amazon.com/athena/latest/ug/what-is.html` (`200 r=0`) |
| b | `dea-t1-2.questions.json:34` (`dea-t1-2-q1` 둘째 출처) | `whitepapers/latest/big-data-analytics-options/aws-lambda.html` | `200 r=1 → lambda/latest/dg/welcome.html` | `https://docs.aws.amazon.com/lambda/latest/dg/welcome.html` (`200 r=0`) |
| c | `dea-t1-2.md:277` (참고자료 15) | `whitepapers/latest/cost-modeling-data-lakes/cost-optimization-in-analytics-services.html` | `200 r=1 → cost-management/latest/userguide/what-is-costmanagement.html` | ⚠️ 아래 주의 |

③ **왜 문제인지** — `big-data-analytics-options` 백서 전체가 각 서비스의 현행 문서로 접혔다. (b)는 `dea-t1-2-q1`이 그 출처에 **「Lambda 함수당 900초 제약」**을 귀속시키는데, 301 대상인 `lambda/latest/dg/welcome.html`에는 그 수치가 없다. 사실 자체는 맞지만 **인용 페이지가 그 사실을 담지 않는** B축 결함이 된다.

⑤ **제안 수정안**
- (a) 301 대상 `athena/latest/ug/what-is.html`로 교체. `dea-t1-2-q7`이 그 출처에 귀속시키는 것은 "커넥터 Lambda 요금과 스캔 과금"인데, 비용 서술은 `https://docs.aws.amazon.com/athena/latest/ug/federated-queries.html`(이미 **첫째 출처**이고 `200 r=0`)이 더 적합하다. 제목을 "Amazon Athena 소개 — 서버리스 SQL 쿼리"로 좁히고 비용 귀속은 첫째 출처에 맡기는 것을 권한다.
- (b) ⚠️ **301 대상이 늘 정답은 아니다**(§5 규율). 900초 한도의 정본은 **`https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html`**이다(같은 레포의 `dea-t1-4-q2`가 이미 이 URL을 「호출 최대 실행 시간」 근거로 쓴다 — **내부에 정답이 있다**). 교체를 권한다.
- (c) ⚠️ **301 대상이 엉뚱하다.** `cost-management` 「What is Cost Management?」는 분석 서비스 비용 최적화를 다루지 않는다. **URL 교체로 닫히지 않는 자리**이므로, 참고자료 15가 인용하던 사실을 확인한 뒤 ① 그 사실을 담은 페이지로 재소싱하거나 ② 항목을 지우고 번호를 당기는 선택이 필요하다(§6에 재소싱 미완으로 남겼다).

⚠️ **가드**: `source_url_retired_test.dart`의 `retiredUrls`에 (a)(b)를 추가하는 것이 그 파일의 운영 규약이다(2026-10-29 감사는 **DEA 리다이렉트 0건**으로 끝났으므로 이 둘은 새 항목이다).

---

## 4. P3 — 보강 후보

### 4-1. SOA-C03

**P3-SOA-1. 정답 인덱스가 index 0에 86.3% 쏠려 있다** — `soa/*.questions.json` 전체(0:259 / 1:30 / 2:9 / 3:2). **학습자에게는 보이지 않는다**(`lib/data/mock_exam.dart:85`의 `randomOptionOrders`가 모든 풀이 경로에서 보기 순서를 섞고, `quiz_page.dart:40`·`review_page.dart:77`이 이를 적용한다 — 실측). 그러나 ① 저작 시 「첫 보기를 정답으로 쓰는」 습관이 굳어 오답 보기의 품질이 떨어질 위험 ② 스냅샷·디버깅 시 사람이 읽는 순서가 늘 정답 먼저라 검수 눈이 둔해지는 위험이 있다. **DEA는 42.6%로 건강하다** — 신규 SOA 문항부터 분산을 권한다. 기존 300문항의 인덱스 재배치는 가드 다수(`soa_question_facts_test`의 「정답 불변」 단정 계열)를 건드리므로 **권하지 않는다.**

**P3-SOA-2. `soa-t1-5-q6` `W2` — 16,000 IOPS / 1,000 MB/s를 gp2에 귀속한다** — `soa-t1-5.questions.json:151, 158`. 보기 2가 "용량과 무관하게 16,000 IOPS와 1,000 MB/s"이고 `W2`가 "16,000 IOPS는 **gp2의 상한에 가까운 값**이며 gp3 베이스라인이 아닙니다."라고 적는다. 공식(`ebs/latest/userguide/general-purpose.html`)으로는 16,000이 gp2의 **정확한 상한**(「가까운」이 아니다)이고, **1,000 MiB/s는 gp2의 값이 아니다**(gp2 최대 처리량은 250 MiB/s). 1,000 MiB/s는 **gp3의 Outposts 한도**이고 일반 리전 gp3 최대는 **2,000 MiB/s**다. 보기 2가 오답인 것은 변하지 않으므로 **정답 불변**이고, `W2`를 "16,000 IOPS는 **gp2의 상한**이고 1,000 MiB/s는 gp2·gp3 어느 쪽의 일반 리전 수치도 아닙니다(gp2 최대 처리량 250 MiB/s, gp3 최대 2,000 MiB/s). 둘 다 gp3 베이스라인이 아닙니다."로 정밀화하는 것을 권한다. **P1-SOA-3과 같은 파일·같은 출처이므로 한 PR로 묶으면 싸다.**

**P3-SOA-3. EC2 자동 복구의 「두 메커니즘」이 빠져 있다** — `soa-t1-4.md` 및 `soa-t1-4-q7`·`q8`·`q9`. 공식 `ec2-instance-recover.html`이 **단순 자동 복구**(인스턴스 시작 시 **기본 활성**)와 **CloudWatch 작업 기반 복구**(시작 후 선택 구성) 둘을 적는데, 현재 콘텐츠는 후자만 다룬다. "By default, simplified automatic recovery is enabled during instance launch."는 시험에서 갈림길이 될 수 있는 사실이다. P2-SOA-5(a)의 URL 교체와 함께 한 줄 추가를 권한다. 아울러 `q7` 해설의 "인메모리 데이터는 **유실될 수 있습니다**"는 공식이 "data stored in volatile memory (RAM) **will be lost**"로 단정하므로 **「유실됩니다」**가 더 정확하다.

**P3-SOA-4. `soa-t1-4-q9` `W1`의 반박이 회피적이다** — 보기 1 "자동 복구는 Nitro 인스턴스에서만 동작하기 때문"에 대한 `W1`이 "인스턴스 세대 제약이 이 시나리오의 핵심이 아닙니다."로 **그 주장이 참인지 거짓인지를 말하지 않는다.** 공식은 지원 인스턴스 유형을 요구 사항으로 적되 "Nitro만"은 아니다. "자동 복구는 **지원되는 인스턴스 유형**에서 동작하며 Nitro 전용이 아닙니다. 또 이 시나리오의 원인은 인스턴스 유형이 아니라 장애 계층입니다."로 바꾸면 F축(오답 근거도 사실 영역) 규율에 맞는다.

**P3-SOA-5. `aws.amazon.com/security-agent/` → `continuum/` 리브랜드 리다이렉트** — `soa-t4-2.md:30`. `200 r=1`로 리다이렉트하지만 **이것은 결함이 아니다.** 같은 문서 `:232`가 이미 "공식 제품 페이지의 제목은 **「AWS Security Agent (now part of AWS Continuum)」** 로, **AWS Continuum**의 일부로 병기돼 있습니다"로 그 리브랜드를 정확히 기록해 두었다. 원하면 `url:`을 도착지로 당겨도 되지만 **지금 상태로도 학습자에게 틀린 정보를 주지 않는다.** 보고 완결성을 위해 적는다.

### 4-2. DEA-C01

**P3-DEA-1. 정답 분포·출처 품질에 보강 필요 없음.** DEA에서 유일하게 적을 만한 것은 `dea-t2-1-q15` `W3`의 "제시된 공식 문서에서 … 서술은 **확인되지 않습니다**"라는 표현이 **작성 과정 메모처럼 보인다**는 점이다. 기계 스캔이 이것을 유일한 메모 후보로 집어냈다. 그러나 이 레포의 기존 판정 기준대로 **「보기의 주장을 부정하는 ~라는 서술은 없습니다」는 정당**하며(CLAUDE.md의 M2 가드 계약이 명시한 예외), 실제로 이 문장은 보기 3(FLAT을 양자화 압축으로 서술)을 부정하는 근거다. **수정 불필요** — §5의 대조군으로 남긴다.

---

## 5. 확인했고 문제 없던 것 (대조군)

「검토했다」의 증거다. 아래는 의심 후보로 올렸다가 **공식 문서로 확인해 정상으로 판정한** 것들이다.

### 5-1. 전수 기계 검증 (G축·F축)

| 항목 | 기대 | 실측 | 비고 |
|---|---|---|---|
| `[텍스트](링크)` (파서 미지원) | 0 | **0** ✅ | 탐지기를 대조군 4종으로 먼저 검증 |
| 단일 `*이탤릭*` (파서 미지원) | 0 | **0** ✅ | 동일 |
| 보기 수 4개 균일 | 556 | **556** ✅ | |
| 지문 중복(앞 60자) | 0 | **0** ✅ | |
| 한 문항 내 보기 중복 | 0 | **0** ✅ | |
| 작성 과정 메모 | 0 | **1 후보 → 정당** | §4-2 |
| 구식 명칭 「적합성 팩」 | 0 | **0** ✅ | 2026-10-30 전파 가드가 유지되고 있다 |
| `verified: false` | 0 | **0** | 556 전부 라이브 |

### 5-2. 닫힌·은퇴 서비스 (D축) — 22종 사전 대조

**⚠️ 자격증별 공식 범위 목록을 근거로 판정했고, 「다른 자격증에서 금지였다」를 근거로 쓰지 않았다.**

- **AWS Glue DataBrew (34개소, DEA)** — **정상이다.** 「종료 후보」로 의심해 공식 페이지를 열었고, `https://docs.aws.amazon.com/databrew/latest/dg/what-is.html` (`200 r=0`)가 현재형으로 "AWS Glue DataBrew **is** a visual data preparation tool that enables users to clean and normalize data without writing any code … choose from **over 250 ready-made transformations** … Because DataBrew **is serverless**"를 적는다. 은퇴·신규 차단 공지를 찾지 못했고 **DEA-C01 공식 가이드가 DataBrew를 4회 언급**한다(레포 `exam_guides/DEA-C01.json` 실측). `dea-t3-1-q12`·`dea-t3-2-q3`·`dea-t3-1.md`·`dea-t3-2.md`의 「250개 넘는 변환 · 서버리스 · 레시피 · 읽기 전용 데이터셋 · 기본 500행 샘플」 서술이 공식과 일치한다. **내 의심이 틀렸다.**
- **CodeCommit (`dea-t1-4.md:167`)** — **모범적으로 처리돼 있다.** "시험 범위상 **v1.1 in-scope 목록에서 CodeCommit이 제거**됐고, Developer Tools 항목은 CLI·CloudFormation·CDK·CodeBuild·CodeDeploy·CodePipeline·Amazon Q입니다(**목록은 비포괄적**)". §5-4 규율(「목록에 없다」 ≠ 「범위 밖」)까지 괄호로 적어 두었다.
- **Snowball Edge (`dea-t2-1-q11` `W3`)** — "**신규 고객에게는 더 이상 제공되지 않습니다**"로 정확히 적고 전용 공지 페이지(`snowball-edge-availability-change.html`)를 출처로 단다. ✅
- **CloudTrail Lake (`dea-t4-4-q11`·`q12`·`q14`)** — "2026-05-31부터 신규 고객에게 열리지 않고 … **CloudTrail 자체(trail·Insights·집계 이벤트)는 영향이 없다**"로 범위까지 가른다. ✅
- **SageMaker Data Wrangler (`dea-t3-2-q6`)** — SageMaker Canvas로 통합된 현황을 정확히 반영. ✅
- **Amazon Q Developer (`soa-t1-4.md:25, 210`)** — Kiro와의 관계를 설명하는 문맥이고 정답 보기로 쓰이지 않는다. 문제없다.
- **은퇴·닫힘이 의심됐으나 레포에 0건**: QLDB · OpsWorks · Cloud9 · Monitron · CodeWhisperer · CodeGuru · Elasticsearch Service · Amazon ML · SimpleDB · CloudSearch · Data Pipeline · Forecast · SageMaker Clarify · Audit Manager · Elastic MapReduce(구명칭).
- **Kinesis Data Analytics (`dea-t1-1.md:197`)** — 개명 함정으로 **의도적으로** 적은 자리다("Kinesis Data Analytics → Managed Service for Apache Flink(SQL 애플리케이션은 단종)"). ✅

### 5-3. 공식 문서로 확인해 정상이었던 수치·사실 (ⓒ축)

| 문항/문서 | 주장 | 공식 근거 | 판정 |
|---|---|---|---|
| `dea-t1-1-q4` | Firehose S3 버퍼 기본 **5 MB / 300초**, 범위 **1~128 MB / 0~900초** | `BufferingHints`: "IntervalInSeconds … The default value is **300**" · "SizeInMBs … The default value is **5**" / Firehose FAQs: "buffer size (1 MB to 128 MB) or buffer interval (**0 to 900 seconds**)" | ✅ **내 의심이 틀렸다** |
| `dea-t1-1-q6` | 제로 버퍼링은 동적 파티셔닝과 **함께 쓸 수 없다**; 형식 변환·동적 파티셔닝 시 버퍼 **64~128 MB** | `create-configure-backup.html`: "**Zero buffering feature is not available for dynamic partitioning.**" / FAQs: "If you have Apache parquet or dynamic partitioning enabled, then your buffer size … ranges from **64MB to 128MB**" | ✅ |
| `dea-t3-3-q6` | 누락 데이터 4종; **AWS/DynamoDB 네임스페이스 기본값은 `ignore`**; `ThrottledRequests`는 `notBreaching` | `alarms-and-missing-data.html`: "The default behavior is `missing`." + **"Alarms that evaluate metrics in the `AWS/DynamoDB` namespace default to `ignore` missing data."** + "for a metric that generates data points only when an error occurs, such as `ThrottledRequests` in Amazon DynamoDB, you would want to treat missing data as `notBreaching`" | ✅ **글자 단위로 일치** |
| `dea-t1-3-q12` `W3` | SNS FIFO 토픽은 이메일·SMS·모바일·HTTP(S)를 구독할 수 **없다** | `fifo-message-delivery.html`: "SNS FIFO topics **can't deliver messages to customer managed endpoints**, such as email addresses, mobile apps, phone numbers for text messaging (SMS), or HTTP(S) endpoints." | ✅ |
| `soa-t2-1-q9` | 수명 주기 후크 기본 대기 **1시간**, 최대 **48시간** | `lifecycle-hooks.html`: "The default timeout for a lifecycle hook is **one hour** (heartbeat timeout). There is also a global timeout … The global timeout is **48 hours** or 100 times the heartbeat timeout, whichever is smaller." | ✅ |
| `soa-t1-5-q6`·`q7`·`q10` | gp3 베이스라인 **3,000 IOPS / 125 MiB/s**; gp2 베이스라인 **3 IOPS/GiB**, 버스트 **3,000**(<1 TiB) | `general-purpose.html`: "gp3 volumes deliver a consistent baseline IOPS performance of **3,000 IOPS**" · "baseline throughput performance of **125 MiB/s**" · "`gp2` volumes smaller than **1 TiB** … can **burst to 3,000 IOPS**" + "**gp3 volumes do not use burst performance**" | ✅ |
| `soa-t1-1-q11` | EventBridge는 **경보 작업이 아니라** 경보가 이벤트를 **내보내는** 곳; 작업 목록에 **Lambda** 포함 | 2026-10-29 감사 §4가 지적한 결함이 2026-11-01에 정정된 상태를 실측 확인 | ✅ **닫혔다** |
| `soa-t2-3-q8`·`q10` | RDS 자동 백업 **1~35일**; 수동 스냅샷은 직접 삭제까지 보존 | 표준 사실, `USER_WorkingWithAutomatedBackups.html` (`200 r=0`) | ✅ |
| `soa-t5-1-q2`·`q12` | /24에서 사용 가능 **251개**(5개 예약); VPC CIDR **/16~/28** | 표준 사실 | ✅ |
| `soa-t5-2-q6`·`q11` | VPN 터널 **2개**; 게이트웨이 엔드포인트는 **S3·DynamoDB만** | 표준 사실; `soa-t5-2-q14` `W2`가 "S3용 인터페이스 엔드포인트도 존재합니다"로 SAA가 배운 함정까지 피한다 | ✅ |
| `soa-t5-4-q3` | Flow Logs 대상 **CloudWatch Logs · S3 · Amazon Data Firehose** | 3종 정확 + **신명칭** 사용 | ✅ |
| `soa-t5-4-q7` | 집계 간격 기본 최대 **10분**, 생성 시 **1분** 지정 가능, Nitro ENI는 지정값과 무관하게 1분 이하 | `flow-log-records.html` | ✅ |
| `dea-t1-3-q3`·`q5` | Express 시작률 **초당 100,000** / Standard **2,000**; Distributed Map **10,000** 병렬, Inline 동시성 **40** | 표준 사실, 출처가 정확한 페이지 | ✅ |
| `dea-t2-1-q6` | Aurora I/O 지출이 **25% 이상**이면 I/O-Optimized; 전환은 **30일에 한 번** | `Aurora.Overview.StorageReliability.html` | ✅ |

### 5-4. `repost.aws` 403 — 죽은 링크가 아니다 (두 번째 방법으로 확인)

문항·학습문서가 쓰는 `repost.aws/knowledge-center/*` **고유 13개**가 기본 `curl`에 `403 r=0`을 준다. **봇 체크이며 죽은 링크가 아니다.** User-Agent 위조를 하지 않고 **AWS 문서 리더**(두 번째 방법)로 본문을 열어 실재를 확인했다 — 예: `mwaa-scheduler-issues`("How do I resolve common issues with my scheduler in Amazon MWAA?" + `scheduler_health_check_threshold` 기본 30초 본문), `athena-invalid-s3-location-error`("How do I troubleshoot output location errors…" 본문). 2026-10-29 감사가 5건을 내장 브라우저로 확인한 것과 같은 결론이고, **md를 포함해 세면 13건**이다.

### 5-5. 2026-10-29 감사가 교체한 URL — 지금도 정상이다

그 감사의 교체 정본을 표집 재측정했고 모두 `200 r=0`이었다: `AWSEC2/latest/UserGuide/ebs-optimized.html` · `AmazonCloudWatch/…/alarm-evaluation.html` · `alarms-and-missing-data.html` · `alarm-actions.html` · `CloudWatch_Alarms.html` · `systems-manager/…/patch-manager-tag-a-patch-group.html` · `IAM/…/confused-deputy.html` · `config/…/evaluate-config_components.html`.

⚠️ **주의 — EBS 문서는 양방향으로 움직였다.** 그 감사가 `ebs/latest/userguide/ebs-optimized.html` → `AWSEC2/latest/UserGuide/ebs-optimized.html`로 교체한 것은 **지금도 맞다**(`AWSEC2` 쪽이 `200 r=0`, `ebs` 쪽이 `200 r=1`). 그런데 P2-SOA-5(b)(c)는 **반대 방향**이다(`AWSEC2` → `ebs`). 즉 **「EBS 문서는 전부 어느 한쪽으로 옮겨졌다」고 일반화하면 틀린다.** 페이지마다 따로 재야 한다.

---

## 6. 측정 한계 (못 본 것과 그 이유)

정직하게 적는다. 아래는 **보지 않았거나, 보았지만 판정을 닫지 못한** 것이다.

### 6-1. 범위상 보지 않은 것

1. **학습문서 본문의 문장 단위 전수 통독** — 37편 1.19MB를 문장마다 공식 대조하지는 않았다. md에 대해 전수로 한 것은 ① URL 647개 실측 ② 파서 미지원 표기 ③ 구식·닫힌 서비스 명칭 22종 ④ 절대 표현(`항상`·`절대`·`유일한`·`무조건`·`모든 경우`) ⑤ 수치 표현(`최대 N`·`기본 N`·`상한 N`) 집계다. **md 발견 7건은 모두 ①④⑤에서 나왔다.** 따라서 **「🧠 원리」 블록·자가 점검 해설·표 안쪽의 서술형 사실은 표집만 했다.** 남은 위험이 가장 큰 곳이 여기다.
2. **자가 점검 정답 ↔ 본문 일치(E축)** — 자동화할 방법이 없어 통독 중 눈에 걸린 것만 봤다. SAA가 `saa-t2-3.md` 자가 점검 Q5에서 "스티키 대상이 사라지면 연결하지 못한다"를 **거꾸로** 적은 사례가 있었던 자리이므로, **SOA 20편 · DEA 17편의 자가 점검 전수 대조는 남은 과제**다.
3. **문항 ↔ 학습문서 파생 일치(E축) 전수** — `section` 참조를 따라 각 문항이 가리키는 절과 본문을 짝지어 대조하지는 않았다. SOA에서 발견한 E축 불일치 3건(Firehose 명칭 · Multi-AZ 수식 · 죽은 URL)은 모두 **다른 축의 스캔에 걸려 부수적으로** 드러난 것이다.
4. **시험 가이드 ↔ `skill` 태그 커버리지** — 각 Task의 공식 목표가 문항에 빠짐없이 덮였는지는 보지 않았다(`soa_guide_v11_test`가 가이드 JSON 동기화를 보지만 커버리지는 다른 축이다).
5. **오디오 대본(`script.json`)** — 범위 밖으로 두었다.

### 6-2. 보았지만 판정을 닫지 못한 것

6. **P2-DEA-3(c) `cost-modeling-data-lakes` 재소싱** — 301 대상(`cost-management` What is)이 원래 인용하던 사실을 담지 않는다. `dea-t1-2.md:277`의 참고자료 15가 무엇을 근거로 삼았는지는 본문 인용이 명시적이지 않아 **대체 페이지를 특정하지 못했다.** URL 교체로 닫히지 않는 자리다.
7. **「공식에 없다」로 끝낼 수 있었던 후보 0건** — §5-2 규율(추출 둘 · 대조군 · 동의어 · 표 구조 · 영문 인용으로 먼저 검색)을 적용할 자리가 실제로 생기지 않았다. 내가 올린 모든 후보는 공식에 **있는** 것으로 확인됐거나(§5-3) 공식이 **다르게** 적는 것으로 확인됐다(§2·§3). 그래서 그 규율의 다섯 단계를 끝까지 쓴 항목은 없다 — **이 보고서에 「공식에 없다」를 근거로 삼은 항목은 하나도 없다.**

### 6-3. 측정 자체의 한계

8. **URL 실측은 네트워크 시점 의존이다** — 2026-11-06 기준이고, CI가 보지 않으므로 다음 저작 때 다시 재야 한다.
9. **「2026-10-29 이후 새로 죽었나」를 완전히 가를 수 없다** — 그 시점의 상태를 직접 재지 못했다(§3-1 P2-SOA-5 말미에 적었다).
10. **`repost.aws` 403 13건은 브라우저 렌더링까지 확인하지 않았다** — AWS 문서 리더로 본문을 읽었으므로 실재는 확정이지만, 학습자 브라우저에서 봇 체크가 걸리는지는 보지 않았다.
11. **가드 충돌은 「읽어서」 판정했고 돌려 보지 않았다** — 지시대로 `flutter test`·`flutter analyze`를 실행하지 않았다. §2·§3의 「가드」 줄은 **테스트 소스를 읽은 결과**이며, 실제 레드 여부는 컨트롤러가 수정 후 확인해야 한다.
12. **정답 쏠림이 「학습자 비노출」이라는 판정은 코드 읽기 기반이다** — `lib/`의 세 호출부를 확인했지만 앱을 띄워 보지는 않았다.

---

## 7. 측정 중 내 판정이 틀렸다가 바로잡힌 자리

사용자가 명시적으로 요청한 항목이다. 다섯 번 틀렸다.

1. **「SOA 정답 쏠림 86.3%는 중대 결함」 → P3로 강등.** 런타임 셔플을 확인하지 않고 F축 P1 후보로 올렸다. `lib/data/mock_exam.dart`·`quiz_page.dart`·`review_page.dart`를 읽고 모든 풀이 경로가 보기 순서를 섞는 것을 확인해 내렸다. **교훈: 데이터의 통계적 편향을 결함이라 부르기 전에 그 데이터를 읽는 코드를 본다.**

2. **「DEA Firehose 수치가 의심스럽다」 → 내가 틀렸다.** 기본 버퍼(5 MB/300초)와 간격 범위(0~900초)를 오류 후보로 올렸으나, 공식 `BufferingHints`가 기본 300/5를 적고 FAQ가 0~900초를 적는다. 게다가 내가 처음 근거로 삼은 `create-configure-backup.html`의 "60–900 seconds"는 **S3 백업 대상**의 범위였고 **주 대상(primary destination)의 범위가 아니었다.** **교훈: 같은 페이지 안에서도 「백업 대상」과 「주 대상」은 다른 절이다 — 인용 전에 그 수치가 어느 절의 것인지 본다.**

3. **「AWS Glue DataBrew는 종료 후보」 → 틀렸다.** 사전 대조에서 34개소가 걸려 D축 P1 후보로 올렸으나, `what-is.html`이 현재형으로 살아 있고 DEA 공식 가이드가 4회 언급한다. **교훈: 「닫힌 서비스」 사전은 다른 자격증 작업에서 온 선입견을 옮기기 쉽다. §5-4 규율대로 각 자격증의 공식 범위 목록을 근거로 삼아야 한다.**

4. **URL 측정 결과의 열 순서를 한 행에서 거꾸로 읽었다.** 출력 형식이 `<상태 r=N -> url_effective>\t<입력 URL>`인데 `continuum/`을 입력으로 착각해 레포에서 찾아 헤맸다. 실제 입력은 `aws.amazon.com/security-agent/`이고, 그것은 **결함이 아니라 `soa-t4-2.md:232`가 이미 기록한 리브랜드**였다. **교훈: 자기 측정 스크립트의 출력 스키마도 대조군으로 확인한다 — 이 행 하나를 거꾸로 읽어 「레포에 없는 URL」이라는 유령을 쫓았다.**

5. **「Regional NAT Gateway」를 SAA 본문을 근거로 쓰려 했다가 멈췄다.** `saa-t1-3.questions.json`이 2025-11 리전 NAT를 적고 있어 그대로 인용할 수 있었지만, 공식 `nat-gateway-basics.html`은 아직 영역형만 적어 **AWS 내부가 갈린 상태**였다. 레포 노트를 정본으로 쓰지 않고 전용 페이지(`nat-gateways-regional.html`)와 발표 블로그를 직접 찾아 확정했다. **교훈: 지시문의 「노트는 단서이고 판정은 공식 실측으로만」이 바로 이 자리를 위한 것이었다. 결과적으로 레포 노트가 맞았지만, 맞았다는 것도 실측으로만 알 수 있었다.**

---

## 8. 컨트롤러에게 — 수정 PR 묶는 제안

가드 `lastVerified` 고정 때문에 **파일 단위로 묶는 것이 싸다.**

| PR | 담는 것 | 함께 올려야 하는 가드 |
|---|---|---|
| ① `soa-t1-5` | P1-SOA-3(gp2 5,334) + P1-SOA-4(Multi-AZ q11·q12·md) + P3-SOA-2(q6 `W2`) | `soa_facts_test.dart:151` · `soa_v11_topics_test.dart:364` 날짜 |
| ② `soa-t5-2` | P1-SOA-1(DX over VPN 6개소 + q8 + MACsec) | `soa_v11_topics_test.dart:371` 날짜 / `_nameRules`에 금지 규칙 추가 권장 |
| ③ NAT 계열 | P1-SOA-2(`t5-1-q5`) + P2-SOA-1(`t5-1.md`·`t2-2.md`·문항 3) | **없음** |
| ④ Multi-AZ 잔여 | P2-SOA-2(`t2-2-q4`·`q14`·`t2-4-q10`) + P2-DEA-2(`dea-t2-1` md 2 + `q6 W3` + 출처 제목) | **없음** (SOA·DEA 동시 정리) |
| ⑤ URL | P2-SOA-5(md 4건) + P2-DEA-3(a)(b) | `source_url_retired_test.dart` `retiredUrls` **6건 추가** / `soa_v11_topics_test.dart:366` 날짜 |
| ⑥ 나머지 | P2-SOA-3(`t2-1.md` 유일한 경로) + P2-SOA-4(`t4-3.md` 유일한 방법) + P2-SOA-6(Firehose 명칭 3) + P2-DEA-1(EFO 단위) + P3-SOA-3·4 | `soa_facts_test.dart:154`(t4-3) · `:155`(t5-4) · `soa_v11_topics_test.dart:365`(t1-2) 날짜 |

**정답 인덱스 변경이 필요한 항목은 하나도 없다.** 19건 전부 지문 한정·해설·오답 근거·URL·명칭 수정으로 닫힌다. 따라서 **사람의 flip 재승인이 필요한 항목도 없다.**

⚠️ **`lastVerified` 날짜 맵은 #313이 「날짜 리터럴 하나로 묶으면 정당한 정정이 막힌다」는 교훈으로 문서별 맵으로 바꿔 둔 것이다.** 지금 그 설계가 의도대로 작동한다 — 문서 하나를 고치면 그 문서의 줄만 올리면 된다.
