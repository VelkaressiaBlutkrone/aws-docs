# SAA-C03 md→문항 전파 실패 검수 체크시트 — 2026-10-20

> 대상: **단일 batch가 아니라 전파 실패 자체**다. 2026-10-19 PR#137~#140이 SAA 학습문서를
> 정정했는데 파생 문항에 전파되지 않은 건을 Task 경계를 넘어 모아 고쳤다
> (`saa-t1-1` · `saa-t2-2` · `saa-t3-9` · `saa-t4-1` · `saa-t4-2` · `saa-t4-4`).
> 전체 문항 원문과 선택지는 `flutter_app/build/saa_review/index.html`을 정본 뷰어로 본다.
> 선행 사례는 [2026-10-20-t1-5-review-sheet.md](2026-10-20-t1-5-review-sheet.md),
> 운영 가이드는 [review-rubric.md](review-rubric.md).

**이 시트의 판정 열은 전부 「AI 권고 — 검수자 확정 필요」다.** `verified` flip과 최종 정답
판정은 사람만 한다(루브릭 머리말). 이 작업은 **flip을 하지 않았다** — `verified` 플래그를
하나도 건드리지 않았다.

## 검수 메타

| 항목 | 값 |
|---|---|
| 검수자 | _(기입)_ |
| 검수일 | _(기입)_ |
| 브랜치 | `saa-review/propagation` |
| 기준 커밋 | `fb0088c` (분기 base = `origin/develop`, PR #164 머지 직후) |
| AI 재검수 수행 | 2026-10-20 · 공식 문서 직접 조회 |
| 영구 가드 | `flutter_app/test/saa_question_propagation_test.dart` (신규) |

## 왜 이 시트인가 — md는 고쳐졌고 문항은 안 고쳐졌다

[saa-t1-5 검수](2026-10-20-t1-5-review-sheet.md)에서 "문서 정정이 파생 문항에 전파되지
않는다"는 구조적 결함이 드러났다. **그 결함이 `saa-t1-5`만의 일인지 확인한 것이 이
작업이다.** 결과: 아니었다.

md 전용 가드(`saa_t1_facts_test.dart` · `saa_t12_t13_facts_test.dart` ·
`saa_t2_t4_facts_test.dart`)가 `isFalse`로 금지한 **문장 리터럴 69건**을 수집해
`assets/content/saa/*.questions.json` 24개 전문과 대조했다. 히트 **17건**(PR #164 머지 후
15건). 그중 **진짜 전파 실패 7건**을 이 PR에서 고쳤다. 같은 방법을 SOA에도 돌렸다 —
`soa_facts_test.dart` 금지 15건 × 문항 20파일에서 **히트 0건**이라 SOA에는 같은 결함이 없다.

### 히트에서 제외한 것과 근거

| 계열 | 히트 | 판정 |
|---|---|---|
| `ap-northeast-2` (문항 6파일) | 6 | **검출기 거짓양성.** 그 가드(G-1.1-08)는 `saa-t1-2.md` 자가 점검 Q1 **구간 안에서만** 이 문자열을 금지한다(질문의 허용 리전과 해설의 허용 리전이 어긋나는 것을 막는 단정). 리전 이름 자체는 어디서든 정당하다. |
| `Aurora Serverless v2` (`saa-t3-5` 1문항 · `saa-t4-3` 5문항) | 2파일 | **사실 오류가 아니라 명칭 현대화 → 별건.** 아래 「별건」 참조. |
| `saa-t1-5` 2건 | 2 | PR #164가 먼저 제거했다. 머지된 파일에서 0건임을 실측하고 영구 가드 목록에 포함했다. |

## 공통 체크

- [x] `saa-review/*` 브랜치에서 작업 (`saa-review/propagation` — SAA 콘텐츠 freeze 규약)
- [x] **Test-First**: 영구 가드를 먼저 쓰고 RED(실패 7건 = 타깃 7건) 확인 후 본문 수정
- [x] `correct`(정답 인덱스)·보기 개수·문항 id — **6파일 전부 무변경** (base와 기계 대조)
- [x] `verified` 플래그 무변경 (`saa-t4-2` 15/15 유지, 나머지 0 유지)
- [x] `content_index`의 `questionCount` 무변경 (문항 수 변동 없음)
- [x] 원문 바이트 치환으로 수정 — CRLF 보존·`sources` 1줄 compact 서식 보존 (bare LF 0 실측)
- [x] 공식 문서 URL 7계열 **실재 확인** (슬러그 추측 없음 — 1건은 리다이렉트를 확인하고 교체)
- [ ] `node tool/saa_review.mjs build` HTML 뷰어 열람 (**사람**)
- [ ] 7문항 판정 확정 (**사람**)
- [ ] flip은 이 작업 범위 밖 — `saa-t4-2`는 이미 flip돼 있고 나머지는 드래프트로 둔다

## 판정표 — 일반 `fix` 5건

- [ ] `saa-t1-1-q10` — 페더레이션 선택(IAM Identity Center) · `verified:false`
  - 현재 정답: IAM Identity Center — 인덱스 1 **(무변경)**
  - **판정: `fix` + `resource`.** 해설이 "**Active Directory 등 SAML 2.0 IdP**와 연동"이라고
    적어 AD를 외부 SAML IdP로 분류했다. 공식 ID 소스는 3갈래다 — Identity Center 디렉터리 ·
    **Active Directory(AWS Directory Service로 연결)** · 외부 IdP(SAML 2.0, Okta·Entra ID 등).
    AD는 AWS Managed Microsoft AD 또는 AD Connector 경로로 붙는 **별개 ID 소스**다.
  - **보기 문구도 함께 고쳤다.** 해설만 고치면 보기 1("SAML IdP를 연동한다")과 해설이
    서로 모순돼 G-1.1-08이 잡는 유형의 내부 불일치를 새로 만든다. 보기를 "기존 Active
    Directory를 ID 소스로 연동한다"로 바꿔 AD 시나리오와 정합시켰다.
  - 출처 추가: `singlesignon/latest/userguide/manage-your-identity-source.html`

- [ ] `saa-t4-2-q14` — Graviton 비용 이점 · **`verified:true` → 라이브 노출 중**
  - 현재 정답: 인덱스 1 **(무변경)** — **보기 문구를 공식 수치로 다듬었다**
  - **판정: `fix` + `resource`.** 해설이 "약 20% 저렴합니다**(Graviton3 기준)**"로 적어
    공식에 없는 세대 한정을 붙였다. 공식 문구는 "AWS Graviton-based instances cost
    **up to 20% less** than comparable x86-based Amazon EC2 instances" — **Graviton 패밀리
    전체** 기준이고 "**최대**"다(현재 공식 페이지는 Graviton5까지 열거한다). 보기 1과
    오답근거[0]의 "약 20%"도 "최대 20%"로 맞췄다 — "약"은 공식 "up to"를 과장한다.
  - 출처 추가: `aws.amazon.com/ec2/graviton/` (20% 문장을 직접 담은 페이지)

- [ ] `saa-t4-1-q8` — EC2 중지 시 EBS 과금 여부 · `verified:false`
  - 현재 정답: 중지 상태에도 계속 과금 — 인덱스 2 **(무변경)**
  - **판정: `fix` + `resource`.** 해설의 "**완전히 삭제(Terminate)해야 볼륨 요금이
    멈춥니다**"가 틀렸다. 공식: 종료 시 볼륨은 `DeleteOnTermination` 값에 따라 삭제되거나
    보존되고(루트 기본 true, 추가 볼륨 기본 false), "**Preserved volumes continue to incur
    charges** … To avoid incurring charges, you must **delete the volume**".
  - **기존 내부 모순도 정리했다.** 오답근거[3]은 이미 "EBS 볼륨은 자동으로 삭제되지
    않습니다 … 자동 삭제 설정을 활성화해야 합니다"라고 **옳게** 말하고 있어 해설과
    충돌했다. 해설을 오답근거 방향으로 맞추고 오답근거에 `DeleteOnTermination`을 명시했다.
  - 출처 추가: `AWSEC2/latest/UserGuide/preserving-volumes-on-termination.html`

- [ ] `saa-t4-1-q2` — S3 Intelligent-Tiering 적합 조건 · `verified:false`
  - 현재 정답: 128 KB 미만은 모니터링 제외 — 인덱스 1 **(무변경)**
  - **판정: `fix`.** 해설이 "소용량 객체가 수백만 개인 버킷에서는 오브젝트당 모니터링
    요금이 **절감액을 초과**할 수 있다"고 경고했는데, 그 요금 자체가 없다. 공식: "objects
    smaller than 128KB … will always be charged at the Frequent Access tier rates, **with no
    monitoring and automation charge**". **손해가 나는 것이 아니라 절감이 없는 것**이다.
    바로 앞 문장("모니터링 대상이 아니어서")과도 모순이었다. 출처(storage-class-intro)는
    이 문장을 담고 있어 유지.

- [ ] `saa-t4-4-q4` — S3 Gateway Endpoint로 NAT 비용 절감 · `verified:false`
  - 현재 정답: Gateway Endpoint — 인덱스 1 **(무변경)**
  - **판정: `fix` + `resource`.** 오답근거[2]가 Interface Endpoint 요금을 "$0.01/GB +
    **시간당 ENI 요금**"으로 적어 과금 단위를 ENI로 돌렸다. 공식: "You will be billed for
    each hour that your VPC endpoint remains provisioned in **each Availability Zone**,
    irrespective of the state of its association with the service." 즉 **엔드포인트 × AZ**
    시간 과금이고 연결 상태와 무관하다. `$0.01/GB`는 공식 요금표에서 **리전 월 1 PB까지**
    구간임을 확인해 그 한정을 붙여 유지했다.
  - 출처 추가: `aws.amazon.com/privatelink/pricing/`

## 판정표 — `rewrite(전제 보강)` 2건

이 둘은 **금지 문장 치환만으로 해결되지 않았다.** 정답을 성립시키는 전제가 문항 본문에
없어서, 출제 의도를 건드려 전제를 보강했다. **`correct` 인덱스와 보기 개수는 그대로 뒀다.**
둘 다 flip 안 된 드래프트라 라이브 위험이 없다.

- [ ] `saa-t3-9-q14` — KDS 샤드 자동 확장 여부 · `verified:false`
  - 현재 정답: "아니다" — 인덱스 0 **(무변경)**
  - **문제:** stem에 **용량 모드 한정이 없었다.** 공식: "With the **on-demand** mode,
    Kinesis Data Streams **automatically manages the shards** in order to provide the
    necessary throughput." 즉 키 정답 0은 프로비저닝 모드에서만 참이고, **오답 처리된
    보기 1("그렇다 — 자동 추가")이 온디맨드 모드에서는 사실상 참**이었다.
  - **수정 전 stem:** "Kinesis Data Streams 스트림의 처리량이 한계에 가까워지고 있다.
    샤드는 처리량이 한계를 초과하면 자동으로 추가되는가?"
  - **수정 후 stem:** "**프로비저닝(Provisioned) 모드로 운영 중인** Kinesis Data Streams
    스트림의 처리량이 한계에 가까워지고 있다. **이 모드에서** 샤드는 처리량이 한계를
    초과하면 자동으로 추가되는가?"
  - **수정 전 보기 0:** "아니다 — 샤드 수는 자동으로 증가하지 않으며, 처리량 한계에
    도달하면 수동으로 샤드를 추가하거나 Shard Split을 사용해야 한다"
  - **수정 후 보기 0:** "아니다 — **프로비저닝 모드에서는** 샤드 수가 자동으로 늘지
    않으며, 처리량 한계에 도달하면 **UpdateShardCount**나 Shard Split으로 직접 늘려야 한다"
  - 해설에 모드별 차이와 현행 모드 구성(**On-demand Standard · On-demand Advantage ·
    Provisioned** 3종), 온디맨드의 이전 30일 피크 2배 수용을 넣었다. 오답근거[1]의
    "Kinesis Data Streams에**는** 자동 샤드 확장 기능이 내장되어 있지 않습니다"라는
    서비스 전체 단정도 프로비저닝 모드 한정으로 고쳤다.
  - 출처 추가: `streams/latest/dev/how-do-i-size-a-stream.html`

- [ ] `saa-t2-2-q3` — Lambda 실행 시간 제한 · `verified:false`
  - 현재 정답: 15분 초과로 강제 종료 — 인덱스 2 **(무변경)**
  - **문제 ①** 해설이 Durable functions를 "**Step Functions(Durable Lambda)**"로 적어
    **Step Functions의 기능인 것처럼** 분류했다. Durable functions는 **Lambda의 기능군**이다.
  - **문제 ②** 키 정답이 "Lambda의 최대 실행 시간은 15분"을 **절대 명제**로 썼다. 공식:
    "The function timeout limits each individual invocation of your function, **up to 15
    minutes by default or 90 minutes for asynchronous and event source mapping invocations
    on Lambda Managed Instances**." → 20분 배치는 LMI에서 **가능**하다.
  - **수정 전 stem:** "…배치 작업을 Lambda로 구현하려 한다. 작업 완료까지 최대 20분이
    소요될 수 있다. 이 설계에서 발생하는 문제는?"
  - **수정 후 stem:** "…배치 작업을 Lambda로 구현하려 한다. **기본(온디맨드) 용량 모드를
    쓰고,** 작업 완료까지 최대 20분이 소요될 수 있다. 이 설계에서 발생하는 문제는?"
  - **수정 전 보기 2:** "Lambda의 최대 실행 시간은 15분이므로 20분 작업은 강제 종료된다"
  - **수정 후 보기 2:** "**기본 용량 모드의** Lambda 함수 타임아웃 **상한**은 15분이므로
    20분 작업은 강제 종료된다"
  - 해설에 LMI 예외(비동기·ESM 호출 최대 90분, **Amazon MQ·DocumentDB ESM은 15분 유지**)를
    명시하고 Durable functions의 소속을 바로잡았다.
  - 출처 추가: `lambda/latest/dg/durable-basic-concepts.html`

## 라이브 영향

- **`saa-t4-2-q14`만 라이브 변경이다.** `saa-t4-2`는 15/15 `verified:true`로 flip된 Task라
  문항 본문이 지금 사이트에 노출된다. 보기 1·해설·오답근거[0]의 "약 20% / Graviton3 기준"이
  "최대 20% / 패밀리 기준"으로 바뀐다. 정답 인덱스는 그대로라 **채점 결과는 바뀌지 않는다.**
- 나머지 6문항(`saa-t1-1` `saa-t2-2` `saa-t3-9` `saa-t4-1`×2 `saa-t4-4`)은 전부
  `verified:false` 드래프트 → **노출 0**.
- 학습문서(`*.md`)는 **하나도 건드리지 않았다.**

## 별건 — `Aurora Serverless v2` 명칭 (이 PR에서 제외)

| 항목 | 내용 |
|---|---|
| 범위 | `saa-t3-5` 1문항(`q8`) · `saa-t4-3` 5문항(`q1` `q8` `q13` `q15` 및 오답근거) — **두 Task 모두 15/15 flip 상태 = 라이브** |
| 걸린 위치 | `stem` · `options` · `explanation` · `wrongExplanations` · **`skill` 라벨** · 출처 `title` |
| 왜 제외 | ① **사실 오류가 아니다.** 공식 RDS 사용자 가이드 제목·본문이 "Aurora serverless"로 바뀌었으나 URL 슬러그(`aurora-serverless-v2.*`)와 AWS 블로그는 여전히 `v2`를 쓴다 — 명칭 현대화다. ② **`skill` 문자열이 사용자 데이터다.** 약점 리포트(`wrongSkills`)가 `skill` 라벨을 키로 적재하므로 라벨을 바꾸면 **기존 적재 키가 고아가 된다** — 마이그레이션 판단이 선행돼야 한다. |
| 다음 단계 | 라벨 마이그레이션 방침을 정한 뒤 별도 PR. 그때 `saa_question_propagation_test.dart`의 `_rules`에 `Aurora Serverless v2`를 추가한다(지금은 의도적으로 제외, 파일 주석에 기록). |

## 영구 가드 — `saa_question_propagation_test.dart`

md 가드가 금지한 문장이 **문항에도 없는지** 검사하는 신규 테스트다. 설계 요점:

- **금지 문장 45건을 명시적 상수 목록(`_rules`)으로 둔다.** 테스트 소스를 파싱하지 않는다
  (가드 파일 서식 변화에 깨지므로). 각 항목에 `origin`(어느 md 가드의 어느 단정)과
  `why`(공식 사실)를 적었다 — 큐레이션이 이 가드의 품질이다.
- **검사 범위에서 오답 보기를 제외한다.** `stem` · `skill` · `options[correct]` ·
  `explanation` · `wrongExplanations`만 본다. 오답 보기는 **일부러 틀린 서술**이라 금지
  문장이 거기 있는 것은 결함이 아니다. 반대로 `wrongExplanations`는 사실 서술이므로
  검사한다 — 실제로 `saa-t4-4-q4`의 오류가 거기 있었다.
- **금지만 못박고 요구는 느슨하게.** 고쳐 넣은 표현을 `isTrue`로 고정하지 않았다(다음
  수정에서 테스트가 먼저 터지는 것을 막는다). 파일 개수 단정도 `>= 24`로 뒀다.
- 69건 중 24건은 **의도적으로 제외**했다: md 부분 구간만 쓰는 단정(`ap-northeast-2`),
  md 표·코드블록 형식 문자열(`| **GWLB** (Gateway LB) | L3/4 |`), 일반 어휘·짧은 수치
  조각(`신뢰한다` `< 1ms` `자동 고가용성` `두 가지 엔진 지원` — 다른 서비스 맥락에서
  정당하다), 반박문이 인용하기 쉬운 과장 표현(`유일한 …`), 그리고 `Aurora Serverless v2`.
  제외 기준과 사유는 파일 상단 주석에 있다.
- **운영 규칙:** md 가드에 새 `isFalse` 단정을 추가하면 **`_rules`에 한 줄 추가**한다.
  이 지침도 파일 상단 주석에 적어 뒀다.

## 게이트 실측

실측값이다(`CLAUDE.md`의 기준선 숫자를 복사하지 않았다).

| 게이트 | 결과 |
|---|---|
| `flutter test` | **1,288 그린** (exit 0). 분기 base `fb0088c` 1,242 + 신규 가드 46 |
| `flutter analyze` | **No issues found!** (0건, 8.8s) |
| `node tool/saa_prescreen.mjs build` | 24 Task **구조·정합성 플래그 0건** |
| 신규 가드 RED 확인 | 본문 수정 **전** `+39 -7` — 실패 7건이 타깃 7건과 정확히 일치 |
