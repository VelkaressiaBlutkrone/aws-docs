# SAA md→문항 전파 실패 — 0단계 실측 + 1단계 판정 (승인 대기)

- 세션: trusting-turing-2955d7 · 분기 base 예정 `origin/develop` = `e306b45`
- 워킹트리 HEAD `f8078f6`(main) 의 `assets/content/saa` · `test` 는 `origin/develop` 과 **diff 0** (실측)
- 동시 작업: PR #164 (`saa-review/t1-5` → develop, 미머지). 그 세션 파일 3개는 손대지 않음.

## 0단계 — 검출기 재현 결과: 히트 17건 (컨트롤러 보고는 4건)

검출 방법: `saa_t1_facts_test.dart`·`saa_t12_t13_facts_test.dart`·`saa_t2_t4_facts_test.dart` 에서
`.contains('<리터럴>'), isFalse` 를 정규식으로 전수 수집(멀티라인 포함, Dart 이스케이프 해제)
→ **금지 리터럴 69건** 을 `assets/content/saa/*.questions.json` 24개 전문과 대조.
스크립트: 이 세션 scratchpad `detect.mjs` (읽기 전용).

같은 방법을 SOA(`soa_facts_test.dart` 금지 15건 × `content/soa/*.questions.json` 20개)에도
돌렸다 — **히트 0건**. SOA 쪽에는 같은 전파 실패가 없다.

### 컨트롤러 목록과의 차이 (4건 → 17건)

| 계열 | 히트 | 처리 |
|---|---|---|
| 컨트롤러가 지목한 4건 | 4 | 대상 |
| `saa-t1-5` (PR #164 소관) | 2 | 제외 |
| **컨트롤러 목록에 없던 진짜 전파 실패** | 3 | 대상 추가 |
| `ap-northeast-2` (검출기 거짓양성) | 6 | 제외 |
| `Aurora Serverless v2` (명칭 전용·live 6문항) | 2(파일) | 별도 작업 제안 |

차이의 원인: 컨트롤러는 "문장" 형태의 리터럴만 센 것으로 보인다. 짧은 조각 리터럴
(`절감액을 초과`, `Step Functions(Durable Lambda)`, `$0.01/GB + 시간당 ENI 요금`)이 빠졌고,
그 3건은 **실제 전파 실패**였다. 반대로 `ap-northeast-2`·`Aurora Serverless v2` 는 전수
대조에서만 걸리는 잡음·명칭 건이다.

#### 제외 근거

- **`ap-northeast-2` (6파일: t1-2 t1-5 t3-1 t3-2 t3-7 t3-8)** — 가드
  `saa_t1_facts_test.dart:76` 은 전역 금지가 아니다. `saa-t1-2.md` 안의 자가 점검 Q1
  **부분 문자열만 잘라** 질문(us-east-1만 허용)과 해설의 모순을 막는 단정이다. 리전 이름
  자체는 어디서든 정당 → **검출기 거짓양성**. 영구 가드 목록에 넣지 않는다.
- **`Aurora Serverless v2` (t3-5 1문항·t4-3 5문항, 전부 `verified:true` = live)** — 공식
  RDS 사용자 가이드 제목·본문이 "Aurora serverless"로 바뀌었으나(`aurora-serverless-v2.how-it-works.html`
  = "How Aurora serverless works"), URL 슬러그와 AWS 블로그는 여전히 `v2` 를 쓴다.
  **사실 오류가 아니라 명칭 현대화**다. 게다가 6문항의 `stem`·`options`·**`skill` 라벨**까지
  걸려 있고 `skill` 문자열은 약점 리포트(`wrongSkills`)에 **사용자 데이터로 적재**된다 →
  이름을 바꾸면 기존 적재 키가 고아가 된다. 데이터 호환 판단이 필요하므로 **이 PR 범위 밖**.

## 1단계 — 판정표 (전부 공식 문서 직접 확인)

| # | 파일 / 문항 | verified | 금지 문장 (위치) | 공식 사실 | 판정 |
|---|---|---|---|---|---|
| 1 | `saa-t1-1` **q10** | false | `Active Directory 등 SAML 2.0 IdP` (explanation) | ID 소스는 3갈래: Identity Center 디렉터리 / **Active Directory(AWS Directory Service 경유)** / 외부 SAML 2.0 IdP(Okta·Entra ID). AD는 외부 SAML IdP가 **아니다** | `fix` |
| 2 | `saa-t4-2` **q14** | **true (LIVE)** | `(Graviton3 기준)` (explanation) | "AWS Graviton-based instances cost **up to 20% less** than comparable x86-based Amazon EC2 instances" — **Graviton 패밀리 전체** 주장이고 "최대"다. 세대 한정(Graviton3) 근거 없음. 현재 페이지는 Graviton5까지 언급 | `fix` |
| 3 | `saa-t4-1` **q8** | false | `완전히 삭제(Terminate)해야 볼륨 요금이 멈춥니다` (explanation) | "Preserved volumes **continue to incur charges** … To avoid incurring charges, you must **delete the volume**." `DeleteOnTermination` 기본값: 루트 true, 그 외 false | `fix` |
| 4 | `saa-t4-1` **q2** | false | `절감액을 초과` (explanation) | "objects smaller than 128KB … always be charged at the Frequent Access tier rates, **with no monitoring and automation charge**" — 128KB 미만엔 모니터링 요금이 **붙지 않는다**. "모니터링 요금이 절감액을 초과"는 성립 불가 | `fix` |
| 5 | `saa-t4-4` **q4** | false | `$0.01/GB + 시간당 ENI 요금` (wrongExplanations.2) | "hourly charge for **each VPC endpoint provisioned in each Availability Zone**, regardless of the state of its association" — 시간 요금은 ENI가 아니라 **엔드포인트×AZ** 단위 | `fix` |
| 6 | `saa-t3-9` **q14** | false | `샤드 수는 자동으로 증가하지 않습니다` (options[0]·explanation·wrongExplanations.1) | "With the **on-demand** mode, Kinesis Data Streams **automatically manages the shards**". 모드는 이제 3종(On-demand Standard / On-demand Advantage / Provisioned) | **`rewrite`** |
| 7 | `saa-t2-2` **q3** | false | `Step Functions(Durable Lambda)` (explanation) | Durable functions는 **Lambda의 기능군**(Step Functions 아님). 또 "function timeout … up to 15 minutes by default **or 90 minutes** for asynchronous and event source mapping invocations on **Lambda Managed Instances**" | **`rewrite`** |

### 근거 URL (실재 확인)

| # | URL |
|---|---|
| 1 | https://docs.aws.amazon.com/singlesignon/latest/userguide/manage-your-identity-source.html |
| 2 | https://aws.amazon.com/ec2/graviton/ (본문 직접 조회) |
| 3 | https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/preserving-volumes-on-termination.html |
| 4 | https://aws.amazon.com/s3/faqs/ · https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html |
| 5 | https://docs.aws.amazon.com/prescriptive-guidance/latest/integrate-third-party-services/architecture-1.html |
| 6 | https://docs.aws.amazon.com/streams/latest/dev/how-do-i-size-a-stream.html |
| 7 | https://docs.aws.amazon.com/lambda/latest/dg/durable-basic-concepts.html · https://docs.aws.amazon.com/lambda/latest/dg/durable-invoking-esm.html |

## `rewrite` 2건 — 왜 멈췄는가

둘 다 **`correct` 인덱스를 바꿀 필요는 없지만, 정답을 성립시키는 전제가 문항 본문에 없다.**
금지 문장을 치환하는 것만으로는 해결되지 않고 stem/options의 **의미를 바꿔야** 한다.

- **q14 (KDS)** — stem "샤드는 처리량이 한계를 초과하면 자동으로 추가되는가?"에 모드 한정이
  없다. 키 정답 0("아니다")은 **프로비저닝 모드에서만** 참이고, 오답 처리된 1("그렇다 —
  자동 추가")은 **온디맨드 모드에서 사실상 참**이다. 최소 수선안: stem에 "프로비저닝 모드"를
  명시 + 해설에 온디맨드 자동 관리(이전 30일 피크의 2배)를 더한다 → `correct` 0 유지.
- **q3 (Lambda)** — stem "20분 배치를 Lambda로" 의 키 정답 2는 "Lambda 최대 실행 시간은
  15분"을 **절대 명제**로 쓴다. 공식은 기본 15분 / **Lambda Managed Instances에서 비동기·
  ESM 호출은 최대 90분**이다. 20분 작업은 LMI에서 **가능**하다. 최소 수선안: options[2]·
  해설을 "기본(온디맨드) 용량 모드 15분"으로 한정 + Durable functions 오라벨 제거 →
  `correct` 2 유지.

둘 다 "원문 치환"이 아니라 출제 의도 재정의라서 지시대로 보고하고 멈췄다.

## 보조 발견

- **#1의 2차 결함:** options[1] "…SAML IdP를 연동한다" 도 AD 시나리오에선 부정확하다.
  explanation만 고치면 **보기와 해설이 서로 모순**된다(가드 G-1.1-08이 잡는 유형의 결함을
  새로 만든다). 보기 문구를 "기존 디렉터리를 ID 소스로 연동한다" 로 함께 완화해야 정합.
- **#3의 2차 결함(이미 존재):** `wrongExplanations.3` 은 이미 "EBS 볼륨은 자동으로 삭제되지
  않습니다 … 자동 삭제 설정을 활성화해야" 라고 옳게 말한다 → explanation과 **내부 모순**.
- **live 노출 범위:** SAA는 24 Task 중 6 Task가 flip됨(`verified:true` **90/360**):
  t2-1 t3-2 t3-4 t3-5 t4-2 t4-3 (각 15/15). 이 중 **#2(t4-2 q14)만 이 PR의 live 변경**이다.
