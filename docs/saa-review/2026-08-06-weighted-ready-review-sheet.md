# SAA-C03 weighted-ready 검수 체크시트 — 2026-08-06

> 대상 batch: `saa-t1-1`, `saa-t1-4`, `saa-t2-5`.
> 전체 문항 원문과 선택지는 `flutter_app/build/saa_review/index.html`을 정본 뷰어로 본다.
> 이 문서는 사람이 놓치기 쉬운 advisory 문항과 Task 단위 pass 체크를 위한 작업표다.

## 검수 메타 (루브릭 §5 승인 로그의 근거)

| 항목 | 값 |
|---|---|
| 검수자 | _(기입)_ |
| 검수일 | _(기입)_ |
| 브랜치 | _(기입 — `saa-review/*`)_ |
| 기준 커밋 | _(기입 — 검수한 `.questions.json`의 커밋 해시)_ |

## 공통 체크

- [ ] `saa-review/*` 브랜치에서 작업 (SAA 콘텐츠 freeze 규약)
- [ ] freeze를 쓸 경우 `core.hooksPath=.githooks` 설정 후 `.saa-frozen` 존재 확인
- [ ] `node tool/saa_prescreen.mjs build` 결과 구조 플래그 0건 확인
- [ ] `node tool/review.mjs build saa` 결과 HTML 뷰어 열람
- [ ] 각 문항에 `review-rubric.md` C1~C6 적용
- [ ] `fix` 반영 후 `saa_prescreen.mjs build` **재실행** → 구조 플래그 0 재확인
- [ ] 사람 검수자가 통과 판정한 Task만 `node tool/review.mjs flip saa <taskId>` 실행
- [ ] flip 후 자동 실행되는 `saa_questions_test` / `content_index_test` 통과 확인

> **선행 조건(2026-10-20):** 아래 집중 확인 5문항은 공식 문서 대조로 전부 `fix` 판정됐고, 수정은 별도 PR로 반영된다. **그 PR이 머지된 뒤** 재검수하고 flip한다 — 수정 전 본문을 기준으로 pass를 주면 구식 해설이 그대로 공개된다.

## `saa-t1-1` IAM — 자격증명·권한·페더레이션

Pass-first 후보: `q1`, `q2`, `q3`, `q4`, `q5`, `q6`, `q7`, `q8`, `q9`, `q10`, `q11`, `q12`, `q14`, `q15`.

집중 확인:

- [ ] `saa-t1-1-q13`
  - Stem: IAM 역할을 수임할 때 STS가 발급하는 자격증명의 성격
  - 현재 정답: 임시 자격증명으로 기본 최대 1시간, 설정에 따라 최대 12시간 후 만료되며 재수임이 필요하다
  - **판정(2026-10-20): `fix`** — C1 정답·12시간 상한은 통과. 충돌 **확인됨**: 오답근거[3]의 "IAM·STS는 글로벌 성격으로 동작합니다"가 현행 설명과 어긋난다. 공식: STS는 **글로벌·리전 엔드포인트를 모두 제공**하고, 기본 활성 리전에서는 글로벌 엔드포인트 요청이 **요청이 발생한 같은 리전에서 처리**되며 opt-in 리전 요청만 US East(버지니아 북부)가 처리한다. **리전 엔드포인트 사용이 베스트 프랙티스.** 발급된 임시 자격증명 자체가 리전에 묶이지 않는다는 오답 근거는 유효하므로 그 논지는 유지하고 "글로벌 서비스" 서술만 교체한다.
  - 미확인: 리뷰가 제시한 "2025-04부터"라는 **시점은 공식 페이지 본문에서 확인하지 못했다** → 날짜를 적지 않는다.
  - 출처: `https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html` + 추가 `https://docs.aws.amazon.com/sdkref/latest/guide/feature-sts-regionalized-endpoints.html`

Task 판정:

| 문항 | C1 | C2 | C3 | C4 | C5 | C6 | 판정 | 메모 |
|---|:-:|:-:|:-:|:-:|:-:|:-:|---|---|
| `saa-t1-1-q1` |  |  |  |  |  |  |  |  |
| `saa-t1-1-q2` |  |  |  |  |  |  |  |  |
| `saa-t1-1-q3` |  |  |  |  |  |  |  |  |
| `saa-t1-1-q4` |  |  |  |  |  |  |  |  |
| `saa-t1-1-q5` |  |  |  |  |  |  |  |  |
| `saa-t1-1-q6` |  |  |  |  |  |  |  |  |
| `saa-t1-1-q7` |  |  |  |  |  |  |  |  |
| `saa-t1-1-q8` |  |  |  |  |  |  |  |  |
| `saa-t1-1-q9` |  |  |  |  |  |  |  |  |
| `saa-t1-1-q10` |  |  |  |  |  |  |  |  |
| `saa-t1-1-q11` |  |  |  |  |  |  |  |  |
| `saa-t1-1-q12` |  |  |  |  |  |  |  |  |
| `saa-t1-1-q13` |  |  |  |  |  |  | **fix** | STS 글로벌 서술 교체(위 집중 확인) |
| `saa-t1-1-q14` |  |  |  |  |  |  |  |  |
| `saa-t1-1-q15` |  |  |  |  |  |  |  |  |

판정값: `pass` / `fix` / `rewrite` / `resource` / `drop` (루브릭 §3). C6은 `saa_prescreen.mjs build`의 구조 플래그 0으로 갈음한다.

- [ ] 전 15문항 pass
- [ ] 필요 수정 반영 후 재검수 (`fix` 반영 PR 머지 후)
- [ ] 사람 flip 대상 확정
- flip 커밋 해시: _(기입)_

## `saa-t1-4` 애플리케이션 보안 — Shield·WAF·Cognito·Secrets Manager

Pass-first 후보: `q1`, `q2`, `q3`, `q5`, `q6`, `q7`, `q8`, `q9`, `q11`, `q13`, `q14`, `q15`.

집중 확인:

- [ ] `saa-t1-4-q4`
  - Stem: AWS WAF 웹 ACL을 직접 연결할 수 없는 리소스
  - 현재 정답: Amazon RDS 데이터베이스 인스턴스
  - **판정(2026-10-20): `fix`** — C1 통과(RDS는 공식 목록에 없음). 최신성 문제 **확인됨**: 공식 보호 대상은 **9종**인데 해설은 7종만 적는다. 누락은 **AWS Amplify**와 **Amazon Bedrock AgentCore Gateway** 둘이다(외부 리뷰는 Amplify만 지적해 AgentCore Gateway를 빠뜨렸다).
  - 공식 9종: CloudFront 배포 · API Gateway REST API · Application Load Balancer · AppSync GraphQL API · Cognito 사용자 풀 · App Runner 서비스 · **Bedrock AgentCore Gateway** · Verified Access 인스턴스 · **Amplify**
  - 출처: 교체 불필요 — 현재 출처 `https://docs.aws.amazon.com/waf/latest/developerguide/what-is-aws-waf.html`가 그 목록을 담은 공식 페이지다.

- [ ] `saa-t1-4-q10`
  - Stem: RDS 비밀번호를 코드에서 제거하고 90일마다 자동 교체
  - 현재 정답: AWS Secrets Manager
  - **판정(2026-10-20): `fix`** — C1 통과. 단정 완화 **필요 확인됨**: 공식 문서는 "관리형 교체에서는 비밀과 DB 자격증명을 갱신하는 데 **Lambda 함수를 쓰지 않는다**"고 못박고, RDS·Aurora·DocumentDB·Redshift **마스터(관리자) 자격증명**과 ECS Service Connect·관리형 외부 비밀이 관리형 교체 대상이다. **그 외 비밀은 Lambda 교체 함수**를 쓴다. 공식 권장은 마스터 대신 최소 권한 애플리케이션 사용자를 쓰는 것이고, 그 경우는 Lambda 교체(교대 사용자 전략)가 맞다.
  - ⚠️ **해설만 고치면 불일치가 남는다** — 정답 선택지 본문 자체가 "Lambda 기반 자동 교체 일정을 90일로 설정한다"다. 선택지와 해설을 같이 손봐야 한다(외부 리뷰는 해설만 지적했다).
  - 출처: 추가 `https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotate-secrets_managed.html`

- [ ] `saa-t1-4-q12`
  - Stem: CloudFront + ALB + EC2 구성에서 WAF 연결 위치
  - 현재 정답: CloudFront 배포에 WAF 연결
  - **판정(2026-10-20): `fix`(조건 해소)** — 오답근거[3]에 "WAF가 지원하는 리소스는 …" 7종 목록이 **실제로 있다**. 따라서 조건부가 아니라 q4와 같은 9종으로 통일한다.
  - 출처:
    - `https://docs.aws.amazon.com/waf/latest/developerguide/what-is-aws-waf.html`
    - `https://docs.aws.amazon.com/waf/latest/developerguide/ddos-overview.html`

Task 판정:

| 문항 | C1 | C2 | C3 | C4 | C5 | C6 | 판정 | 메모 |
|---|:-:|:-:|:-:|:-:|:-:|:-:|---|---|
| `saa-t1-4-q1` |  |  |  |  |  |  |  |  |
| `saa-t1-4-q2` |  |  |  |  |  |  |  |  |
| `saa-t1-4-q3` |  |  |  |  |  |  |  |  |
| `saa-t1-4-q4` |  |  |  |  |  |  | **fix** | WAF 보호 대상 9종으로(위 집중 확인) |
| `saa-t1-4-q5` |  |  |  |  |  |  |  |  |
| `saa-t1-4-q6` |  |  |  |  |  |  |  |  |
| `saa-t1-4-q7` |  |  |  |  |  |  |  |  |
| `saa-t1-4-q8` |  |  |  |  |  |  |  |  |
| `saa-t1-4-q9` |  |  |  |  |  |  |  |  |
| `saa-t1-4-q10` |  |  |  |  |  |  | **fix** | 관리형 교체, 선택지까지(위 집중 확인) |
| `saa-t1-4-q11` |  |  |  |  |  |  |  |  |
| `saa-t1-4-q12` |  |  |  |  |  |  | **fix** | q4와 같은 9종으로 통일(위 집중 확인) |
| `saa-t1-4-q13` |  |  |  |  |  |  |  |  |
| `saa-t1-4-q14` |  |  |  |  |  |  |  |  |
| `saa-t1-4-q15` |  |  |  |  |  |  |  |  |

판정값: `pass` / `fix` / `rewrite` / `resource` / `drop` (루브릭 §3). C6은 `saa_prescreen.mjs build`의 구조 플래그 0으로 갈음한다.

- [ ] 전 15문항 pass
- [ ] 필요 수정 반영 후 재검수 (`fix` 반영 PR 머지 후)
- [ ] 사람 flip 대상 확정
- flip 커밋 해시: _(기입)_

## `saa-t2-5` DR 전략 — RTO·RPO·Pilot Light·Warm Standby·Active-Active

Pass-first 후보: `q1`, `q2`, `q3`, `q4`, `q5`, `q6`, `q7`, `q9`, `q10`, `q11`, `q12`, `q13`, `q14`, `q15`.

집중 확인:

- [ ] `saa-t2-5-q8`
  - Stem: Aurora 데이터베이스 교차 리전 복제로 RPO 최소화
  - 현재 정답: Aurora Global Database
  - **판정(2026-10-20): `fix`** — C1 통과. 혼동 **확인됨**: 오답근거[3]의 "같은 리전 내 Read Replica도 동기 복제가 아니다"는 Aurora 복제본의 동작을 잘못 전달한다. 공식: **Aurora 복제본은 같은 리전에서 프라이머리와 같은 데이터 볼륨을 공유해 복제 지연이 사실상 없다(통상 수십 ms)**. 반면 Aurora 글로벌 DB의 교차 리전 복제는 스토리지 블록 기반 **비동기**이며 지연은 **통상 1초 미만**이다. 따라서 "Aurora 복제본은 스토리지 공유라 리전 장애 DR 수단이 아니다 / RDS(비 Aurora) 읽기 전용 복제본은 비동기 복제다"로 구분해 적는다.
  - 수치: "1초 미만 복제 지연"은 공식 문구와 일치(통상값이므로 **"통상"** 단서를 남겨 보장값으로 읽히지 않게 한다). **"1분 내 승격"은 이번 검증에서 독립 확인하지 못했다** → 문구를 바꾸지 않고 그대로 두되, 확인 못 한 주장으로 기록한다.
  - 출처: 추가 `https://docs.aws.amazon.com/rds/latest/auroraextendedcontent/aurora-faq-availability-and-durability.html`(복제 지연) · `https://docs.aws.amazon.com/prescriptive-guidance/latest/aurora-replication-options/aurora-global-database.html`(비동기·1초 미만)

Task 판정:

| 문항 | C1 | C2 | C3 | C4 | C5 | C6 | 판정 | 메모 |
|---|:-:|:-:|:-:|:-:|:-:|:-:|---|---|
| `saa-t2-5-q1` |  |  |  |  |  |  |  |  |
| `saa-t2-5-q2` |  |  |  |  |  |  |  |  |
| `saa-t2-5-q3` |  |  |  |  |  |  |  |  |
| `saa-t2-5-q4` |  |  |  |  |  |  |  |  |
| `saa-t2-5-q5` |  |  |  |  |  |  |  |  |
| `saa-t2-5-q6` |  |  |  |  |  |  |  |  |
| `saa-t2-5-q7` |  |  |  |  |  |  |  |  |
| `saa-t2-5-q8` |  |  |  |  |  |  | **fix** | Aurora 복제본/RDS 복제본 구분(위 집중 확인) |
| `saa-t2-5-q9` |  |  |  |  |  |  |  |  |
| `saa-t2-5-q10` |  |  |  |  |  |  |  |  |
| `saa-t2-5-q11` |  |  |  |  |  |  |  |  |
| `saa-t2-5-q12` |  |  |  |  |  |  |  |  |
| `saa-t2-5-q13` |  |  |  |  |  |  |  |  |
| `saa-t2-5-q14` |  |  |  |  |  |  |  |  |
| `saa-t2-5-q15` |  |  |  |  |  |  |  |  |

판정값: `pass` / `fix` / `rewrite` / `resource` / `drop` (루브릭 §3). C6은 `saa_prescreen.mjs build`의 구조 플래그 0으로 갈음한다.

- [ ] 전 15문항 pass
- [ ] 필요 수정 반영 후 재검수 (`fix` 반영 PR 머지 후)
- [ ] 사람 flip 대상 확정
- flip 커밋 해시: _(기입)_

## Flip 순서

```powershell
cd flutter_app
node tool/review.mjs flip saa saa-t1-1
node tool/review.mjs flip saa saa-t1-4
node tool/review.mjs flip saa saa-t2-5
```

세 Task가 모두 flip되면 SAA-C03 readiness는 D1 30/19, D2 30/17, D3 45/16, D4 30/13이 되어 **루브릭 §1 개정본(도메인별 weighted capacity) 기준으로** 공개 조건을 충족한다. 단, 그 시점의 D1 노출 문항은 공식 Task 1.3(데이터 보안)을 다루지 않는다 — `saa-t1-5`가 1순위 보강 batch다([batch 문서](2026-08-06-weighted-ready-batch.md) 리스크 항목).
