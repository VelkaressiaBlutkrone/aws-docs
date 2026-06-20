# CLF-C02 학습/모의고사 표적 보충 — 설계 스펙

작성일: 2026-06-20
상태: **구현 플랜 작성·검증·정렬 완료(2026-06-20)**. 구현 플랜: `docs/superpowers/plans/2026-06-20-clf-c02-content-supplement.md`(공식 출처 seed·Phase 0~4·사람 검수 산출물). 본 스펙은 그 플랜과 문항 수·서비스 상태·README 범위를 정렬함.

근거 결정 체인: 사용자가 `D:\Download\aws`(CCP 강의 HTML 학습팩)를 소재로 CLF 학습/모의고사 보충 요청(2026-06-20) → 갭 분석 우선 합의 → 소스 채굴·현행 커버리지 본문 대조로 "진짜 갭" 확정 → **기존 문서 인플레이스 보강**(새 Task 0) · **주제당 +~3 verified 문항**(총 ~25) · **핵심 4문서 + 소소 전부** 범위 확정(사용자, 2026-06-20).

---

## 1. 배경 / 문제

- 소스 `D:\Download\aws\`는 AWS CCP(CLF-C02) 강의(강의 1~274)를 25개 HTML로 정리한 학습팩이다(`index.html` 코스 홈 + 강의별 `lesson-plus`·`study-boost`·미니퀴즈, 25번 파일에 모의고사 안내).
- 현재 프로젝트 CLF-C02 콘텐츠는 이미 충실하다: **19 Task** 학습문서(.md) + **285 verified 문항**(각 Task 15, `2026-06-12-clf-question-density-15`로 달성). 각 문서는 고도화 템플릿(용어 표·🧠 원리 블록·함정 원리 포인터·원리형 자가점검)을 갖춘 정본 수준이고, 공식 시험 가이드 Task에 1:1 매핑(`coversTasks`)된다.
- 따라서 소스로 "대체"하면 품질이 내려간다. 소스는 **소재(raw material)**로만 가치가 있다.

### 1.1 소스 채굴 결과 (확정)

읽기 전용 분석 2건으로 25개 HTML 전수 채굴(원본: `D:\Download\aws\_mined_1.md`, `_mined_2.md` — 레포 외부).

- **출제형 문항은 5개뿐**: 274강 전체에서 시나리오+구체 정답을 가진 진짜 연습문제는 25번 파일 Q1~Q5(Macie·Spot·CloudFront·CodeCommit·다중 AZ)뿐. 나머지 미니퀴즈·exam-drill은 전부 **자동생성 보일러플레이트**("'OOO'가 정답이 되는 키워드는?" + 반복 정답)다. → 소스는 문항 대량 공급원이 **못 된다**.
- **진짜 가치 = 비교/시나리오 표**: 12번 "상황→서비스 매핑표"(DB·분석 14행), EC2 구매옵션 7종, S3 스토리지 클래스, 혼동 페어 비교표 다수(SG↔NACL, DX↔VPN, CloudFront↔GA, SQS/SNS/Kinesis/MQ, GuardDuty/Inspector/Macie 등). → **신규 문항의 출제 소재**로 활용.

## 2. 목표 / 성공 기준

- 소스가 다루지만 **현재 CLF 문서 본문에 없는(또는 이름만 있는) 주제**를 기존 19 Task 문서에 보강한다(아래 §4 확정 갭).
- 보강 주제에 **verified 문항을 추가**한다: **초안 21개** 기준(t3-1 +5·t2-3 +3·t3-7 +4·t2-2 +3·t3-3/t3-8/t3-5 각 +2), 검수 후 18~21 flip 정상, 상한 25. (Forecast는 신규 고객 제한 레거시라 문항 제외 — §4 주.)
- 기존 구조·품질·게이트를 **깨지 않는다**: 새 Task 0, 공식 1:1 매핑 유지, 고도화 템플릿·문항 스키마·테스트 가드 준수.
- 모든 사실은 **공식 AWS 문서로 대조**(소스 HTML은 주제 발굴·출제 소재일 뿐, 사실 근거가 아니다).

## 3. 설계 결정 (승인됨)

| 결정 | 값 | 근거 |
|---|---|---|
| 보강 구조 | **인플레이스**(기존 .md에 섹션 추가, 새 Task 0) | 공식 1:1 매핑 유지 · `content_index.dart` 변경은 테스트·공개 게이트 사고가 잦음 |
| 문항 규모 | **초안 21**(핵심 5/3/4/3 · 소소 각 2), 검수 후 18~21 flip, ≤25 | 절제·품질·공식출처 대조 부담의 균형 |
| 보강 범위 | **핵심 4문서 + 소소 전부** | 사용자 "기존에 없는 내용은 모두 보강" 지시 |
| 깊이 | 핵심은 두텁게, 소소는 가볍게("위치만") | CLF 범위 집중·절제 철학 |

## 4. 확정 갭 → 문서 보강 매핑 (본문 검증 완료)

현행 19개 .md 본문을 서비스명 grep으로 전수 대조해 "완전 누락 / 이름만 / 이미 커버됨"을 가렸다.

| # | 대상 문서 | 보강 주제 (진짜 누락) | 깊이 | 비고(이미 커버돼 제외) |
|---|---|---|---|---|
| 1 | **t3-1** (배포·운영 3.1) | 새 대섹션 **배포·운영 자동화 도구**: Elastic Beanstalk(완전누락)·AWS CDK·Systems Manager 본체(Session Manager·Run Command·Patch·Parameter Store)·Code\* 시리즈 역할(현 t3-8에 *이름만*) + 비교표(CloudFormation vs Beanstalk vs Code\* vs SSM) | **두텁게** | 현 t3-1은 콘솔/CLI/SDK/IaC(CloudFormation)만 |
| 2 | **t2-3** (IAM 2.3) | **Amazon Cognito**(User/Identity Pool)·**AWS Directory Service**(Managed Microsoft AD·AD Connector·Simple AD) | 중간 | IAM·Identity Center·Secrets Manager는 이미 있음. Cognito는 현재 t2-4에 *이름만* |
| 3 | **t3-7** (AI/ML·분석 3.7) | **Rekognition·Comprehend·Textract·Personalize** (+ Forecast는 *신규 고객 제한 레거시*로 문서에만 명시·문항 제외) | 중간 | SageMaker·Lex·Kendra·Translate·Transcribe·**Polly** 이미 있음 |
| 4 | **t2-2** (보안·거버넌스 2.2) | **ACM**(Certificate Manager)·**CloudHSM** — KMS와 구분 | 중간 | KMS·암호화(전송/저장) 이미 있음 |
| 5a | **t3-3** (컴퓨팅 3.3) | **ECR**·**AWS Batch** | 가볍게 | AMI·Lightsail·EC2 Auto Scaling 이미 있음 |
| 5b | **t3-8** (기타 3.8) | **AppStream 2.0**(현 공식명 *Amazon WorkSpaces Applications* — 신·구 명칭 병기)·**Amazon MQ** | 가볍게 | WorkSpaces·SNS/SQS/EventBridge 이미 있음 |
| 5c | **t3-5** (네트워크 3.5) | **VPC Flow Logs**·**PrivateLink** 명시 | 가볍게 | IGW·VPC Endpoint·NAT·Transit Gateway 이미 있음 |

> 채굴 원본의 SAA급 과도 디테일(FSx 3종 심화, Kinesis Firehose 내부 등)은 CLF 범위·절제 원칙으로 **제외**한다.

## 5. 학습문서 보강 규칙 (고도화 템플릿 준수)

`content_enrichment_test`가 강제하는 마커를 보강분도 지켜야 한다.

- **보강 섹션은 `### ` 레벨**로 핵심 개념(`## 📖`) 영역 안에 추가하고, **각 `### ` 보강 섹션에 `> 🧠 원리:` 블록을 동반**한다(가드: 핵심 개념 `### ` 서브섹션 수 하한 min(개수, 8) — 8 초과 문서는 강제되지 않으나 품질상 권장).
- `## 🔤 먼저 알아야 할 용어` 섹션 위치(🎯와 📖 사이)·`## 🧪 자가 점검`의 "왜~인가" 원리형 문항은 **유지**(테스트가 검증).
- 세부 facet은 `#### ` 레벨 사용 가능(파서는 H1~H6 지원·`^### `만 원리 카운트 — [[study-doc-parser-md-subset]]).
- 새 앵커 `{#id}`는 중복 없이, `section_anchor_link_test`·`cert_detail_sections_test` 무결성 유지.
- frontmatter `sources`에 보강 주제의 **공식 AWS 문서 출처를 추가**하고 `lastVerified` 갱신. 무출처 수치·내부 구현 단정 금지(고도화 절제 규칙).
- **흔한 함정** 항목을 보강 주제에 맞게 1~2개 추가(원리 포인터 병기) — 이는 함정형 문항의 출제 자산이 된다.

## 6. 문항 추가 규칙 (`clf-question-density-15` 워크플로우 이식)

- **순서 의존성(철칙)**: 문서 보강 → 그 다음 문항. 모든 신규 문항은 **보강된 문서 본문·원리 블록·함정·frontmatter 출처 범위 내에서만** 출제(새 개념 도입 금지 — density-15 §2 전례 교훈). 본 작업은 문서를 먼저 보강하므로 이 철칙과 정합한다.
- **id 규칙**: 해당 파일 기존 최대 연번 다음부터(`clf-tX-Y-q16`~). 드래프터가 실측 확인.
- **스키마 동일**: `id`·`examGuideTaskId`·`skill`·`difficulty`·`stem`·`options[4]`·`correct`·`explanation`·`wrongExplanations`(정답 제외 3키)·`sources`(보강 문서 출처 범위 내)·`section`(보강 섹션 앵커로 딥링크)·`verified:false`(초안).
- **유형**: density-15 §4.1 체계 준용 — 보강 주제는 주로 **미커버 보완**(새 보강 소재 기반), 가능하면 **원리형**(보강 섹션의 🧠 블록 적용)·**함정 혼동형**(추가한 함정 기반) 혼합. 기존 15문항·자가점검과 **소재·각도 중복 금지**.
- **생산 파이프라인**: 드래프터(verified:false 삽입) → 통합 AI 리뷰어(사실·범위·중복·오답매력·스키마 검증, 수정 권한) → 컨트롤러 실측(JSON 파스·문항 수·`flutter test`) → **사람 검수 게이트(STOP)** → `verified:true` flip + `content_index.dart` questionCount 동기화.

## 7. 테스트 · 게이트 (확인된 불변식)

- **`content_index_test` 동적 불변식**: 모든 Task `questionCount` == 그 `.questions.json`의 `verified:true` 수. 문항 flip 시 `content_index.dart` 동기화 필수.
- **`content_enrichment_test`**: 용어 섹션 위치 · `### ` 서브섹션 🧠 원리 블록(하한 min,8) · 자가점검 "왜" 문항.
- **`question_model_test`**: Task당 verified **`≥15`(하한)** — 보강 Task가 18이 돼도 통과(균일 강제 아님). 스키마 검증.
- **`all_content_parse_test`**: 전 .md 파싱 회귀(헤딩·구조).
- **`section_anchor_link_test` / `cert_detail_sections_test`**: 새 `{#anchor}` 딥링크 무결성.
- **`mock_exam_test`**: 샘플러(추가 문항이 풀에 정상 편입).
- **`flutter analyze`**: 신규 경고·에러 0(기존 잔존 3건 외).
- 초안(verified:false)은 노출·카운트 불변이라 작업 중 전 테스트 그린 유지(flip 시점에만 questionCount 갱신).

## 8. 작업 분할 / 순서

- 브랜치: `develop`에서 `docs/clf-c02-supplement` 분기([[git-branch-flow]] — main 직접 금지, develop 경유 PR). 현재 워킹트리의 무관한 SAA 변경(6파일)은 **건드리지 않는다**(선택적 스테이징).
- **Phase 1 — 학습문서 보강**: 도메인 lane으로 분할(서브에이전트 scope-lock — 단일 문서·명세 제공·완료 후 정지·임의 구현 금지, 컨트롤러가 diff·테스트 직접 검증 [[subagent-scope]]).
  - lane A: t3-1(배포도구, 최대) · lane B: t2-3·t2-2(보안/아이덴티티) · lane C: t3-7(AI) · lane D: t3-3·t3-8·t3-5(소소)
- **Phase 2 — 문항 추가**: §6 파이프라인으로 보강된 문서 기준 드래프트→리뷰→검수 flip. 도메인 배치로 검수 게이트.
- 각 Phase 후 `flutter test`·`flutter analyze` 그린 확인. PowerShell로 `flutter build web` 검증(필요 시 — [[flutter-build-web-powershell]]).

## 9. 비범위 (NOT in scope)

- 새 Task·새 자격증 추가, `content_index.dart` 구조(엔트리 수·도메인) 변경.
- 소스 보일러플레이트 문항 복붙(품질 미달 — 전량 배제).
- SAA급 과도 디테일·CLF 범위 밖 서비스 심화.
- 모의고사 엔진·렌더러·앱 코드 변경(questionCount 갱신·테스트 가드 제외).
- 기존 285문항·기존 문서 본문의 비-보강 영역 개작(보강 주제 인접 최소 편집 외).

## 10. 완료 정의 (Definition of Done)

- §4의 7개 보강 주제가 해당 문서에 고도화 템플릿 준수로 반영(🧠 원리 블록·출처·함정 포함).
- 보강 주제별 verified 문항(초안 21, 검수 후 18~21) 추가·사람 검수 flip, 해당 `questionCount` 동기화.
- `flutter test` 전부 그린(content_index 동적 불변식·enrichment·question_model ≥15·parse·anchor·mock 포함) · `flutter analyze` 신규 0.
- **README CLF 문항 수 갱신**(현재 stale `228/12` → 최종 verified 합계, 예상 285→306): 이번 범위에 포함.
- `develop`로 PR(CI 그린) → 머지. 릴리스(`develop`→`main`)는 별도 시점.

## 11. 리스크 / 주의

- **범위 확장 압력**: 소스가 방대해 "더 넣고 싶은" 유혹 — §4 확정 갭·§9 비범위로 절단. 깊이는 핵심/소소 차등.
- **문서 길이 비대**: t3-1에 배포도구 대섹션 추가 시 문서가 커짐 — 원리 블록 하한 8 캡 활용, 고가치 섹션 우선.
- **공식출처 대조 부담**: 보강 주제마다 공식 문서 확인(소스 HTML 신뢰 금지). Context7/공식 docs 사용.
- **서브에이전트 범위 이탈**: scope-lock 지시 + 컨트롤러 diff·커밋 로그·테스트 직접 검증([[subagent-scope]]·[[subagent-git-branch-pollution]]).
- **문항 중복**: 보강 Task 기존 15 + 자가점검과 소재 충돌 — 리뷰어 전수 대조.

## 12. 파일 / 참조

- 대상: `flutter_app/assets/content/clf/{t3-1,t2-3,t3-7,t2-2,t3-3,t3-8,t3-5}.md` + 각 `.questions.json` · `flutter_app/lib/data/content_index.dart`(questionCount만).
- 게이트: `flutter_app/test/{content_index_test,content_enrichment_test,question_model_test,all_content_parse_test,section_anchor_link_test,cert_detail_sections_test,mock_exam_test}.dart`.
- 소재 원본(레포 외부): `D:\Download\aws\_mined_1.md`·`_mined_2.md` · 강의 HTML 25개.
- 구현 플랜: `docs/superpowers/plans/2026-06-20-clf-c02-content-supplement.md`.
- 서비스 상태 검증(2026-06-20, 공식 문서): Forecast 신규 고객 제한(`what-is-forecast`) · AppStream 2.0→WorkSpaces Applications(`what-is-appstream`) · README 문항수 stale(`228/12`).
- 선행 스펙: `2026-06-11-content-enrichment-design.md`(고도화 템플릿) · `2026-06-12-clf-question-density-15-design.md`(문항 워크플로우·가드). 메모리: [[question-bank-verified-workflow]]·[[subagent-scope]]·[[study-doc-parser-md-subset]].
