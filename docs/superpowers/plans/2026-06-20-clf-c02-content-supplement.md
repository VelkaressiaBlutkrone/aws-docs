# CLF-C02 콘텐츠 표적 보충 — 실행 보강 플랜

작성일: 2026-06-20
상태: **실행 대기** — 원문 스펙 검토 후 수정·보강한 구현 플랜
원문: `docs/superpowers/specs/2026-06-20-clf-c02-content-supplement-design.md`

이 문서는 원문 스펙의 결정을 유지하되, 다음 작업자가 바로 실행할 수 있도록 누락된 작업 단위, 문항 배분, 공식 출처 대조, 테스트 게이트, 사람 검수 산출물을 보강한다.

## 0. 원문 검토 결과

유지한다.

- 기존 19개 CLF Task 문서에 **인플레이스 보강**한다. 새 Task를 만들지 않는다.
- 소스 HTML은 주제 발굴 소재일 뿐, 사실 근거가 아니다. 모든 보강 사실은 AWS 공식 문서로 대조한다.
- 문서 보강 후에만 문항을 만든다. 신규 문항은 보강 본문·원리 블록·함정·frontmatter 출처 범위 안에서만 출제한다.
- 문항 초안은 `verified:false`로 넣고, 사람 검수 뒤에만 `verified:true`로 전환한다.
- `content_index.dart`의 `questionCount`는 `verified:true` 전환 커밋에서만 갱신한다.

수정·보강한다.

- 원문은 "핵심 4주제 각 ~3 + 소소 합 ~6"과 "총 약 20, 상한 ~25"가 섞여 있다. 이 플랜은 **초안 21문항**을 기준으로 잡고, 사람 검수 후 **18~21문항 flip**을 정상 범위로 둔다. 상한은 계속 25문항이다.
- Amazon Forecast는 공식 문서상 신규 고객에게 더 이상 제공되지 않는다. 문서에는 레거시 상태를 명시하되, 별도 문항 출제는 기본 제외한다.
- AppStream 2.0은 공식 문서 제목이 Amazon WorkSpaces Applications로 바뀌어 있다. 학습 문서에는 **"AppStream 2.0(현재 WorkSpaces Applications)"**처럼 시험·강의 명칭과 현재 공식 명칭을 함께 적는다.
- 현재 CLF 전체 raw question JSON을 훑는 전용 드래프트 스키마 가드가 없다. `saa_questions_test.dart` 패턴을 이식한 CLF 보강 전용 raw 검사를 먼저 추가하거나, 최소한 검수 전 스크립트로 동일 조건을 검사한다.

## 1. 성공 기준

- `flutter_app/assets/content/clf/{t3-1,t2-3,t3-7,t2-2,t3-3,t3-8,t3-5}.md`에 확정 갭이 반영된다.
- 각 보강 섹션은 `## 📖 핵심 개념` 안의 `### ` 헤딩으로 들어가고, 최소 1개의 `> 🧠 원리:` 블록과 시험 포인트·함정 포인터를 가진다.
- 보강 주제 공식 출처가 frontmatter `sources`와 `### 📌 출처 (verified)`에 반영된다.
- 사람 검수 전까지 `lastVerified`는 기존 값을 유지한다. 사람 검수 반영 커밋에서만 실제 검수일로 갱신한다.
- 신규 문항 초안 21개가 `q16`부터 연속 id로 추가되고 모두 `verified:false`다.
- 사람 검수 후 승인 문항만 `verified:true`로 전환하고, 해당 Task의 `questionCount`가 실제 verified 수와 일치한다.
- 최종 게이트: `flutter test` 전체 통과, `flutter analyze` 신규 경고 0.

## 2. 작업 전 가드

현재 브랜치가 이미 `docs/clf-c02-supplement`이면 그대로 진행한다. 새로 시작한다면:

```powershell
git switch develop
git pull
git switch -c docs/clf-c02-supplement
```

작업 전 상태 확인:

```powershell
git status --short --branch
cd flutter_app
flutter test test/content_enrichment_test.dart test/all_content_parse_test.dart test/section_anchor_link_test.dart test/content_index_test.dart
```

주의:

- 현재 워킹트리에 무관한 SAA 변경이나 `.claude/` 변경이 있으면 건드리지 않는다.
- 선택적 스테이징만 한다. `git add -A` 금지.
- 문서 편집과 문항 편집은 커밋을 분리한다.

## 3. 공식 출처 seed

각 문서 보강자는 아래 URL을 시작점으로 사용한다. 사실 진술은 이 표 또는 각 서비스의 공식 문서 하위 페이지에서 확인한 범위 안으로 제한한다.

| 문서 | 보강 주제 | 공식 출처 seed |
|---|---|---|
| `t3-1.md` | Elastic Beanstalk | <https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/Welcome.html> |
| `t3-1.md` | AWS CDK | <https://docs.aws.amazon.com/cdk/v2/guide/home.html> |
| `t3-1.md` | Systems Manager | <https://docs.aws.amazon.com/systems-manager/latest/userguide/what-is-systems-manager.html> |
| `t3-1.md` | CodePipeline | <https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html> |
| `t3-1.md` | CodeBuild | <https://docs.aws.amazon.com/codebuild/latest/userguide/welcome.html> |
| `t3-1.md` | CodeDeploy | <https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html> |
| `t3-1.md` | CodeCommit | <https://docs.aws.amazon.com/codecommit/latest/userguide/welcome.html> |
| `t2-3.md` | Cognito | <https://docs.aws.amazon.com/cognito/latest/developerguide/what-is-amazon-cognito.html> |
| `t2-3.md` | Directory Service | <https://docs.aws.amazon.com/directoryservice/latest/admin-guide/what_is.html> |
| `t3-7.md` | Rekognition | <https://docs.aws.amazon.com/rekognition/latest/dg/what-is.html> |
| `t3-7.md` | Comprehend | <https://docs.aws.amazon.com/comprehend/latest/dg/what-is.html> |
| `t3-7.md` | Textract | <https://docs.aws.amazon.com/textract/latest/dg/what-is.html> |
| `t3-7.md` | Forecast | <https://docs.aws.amazon.com/forecast/latest/dg/what-is-forecast.html> |
| `t3-7.md` | Personalize | <https://docs.aws.amazon.com/personalize/latest/dg/what-is-personalize.html> |
| `t2-2.md` | ACM | <https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html> |
| `t2-2.md` | CloudHSM | <https://docs.aws.amazon.com/cloudhsm/latest/userguide/introduction.html> |
| `t3-3.md` | ECR | <https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html> |
| `t3-3.md` | AWS Batch | <https://docs.aws.amazon.com/batch/latest/userguide/what-is-batch.html> |
| `t3-8.md` | AppStream 2.0 / WorkSpaces Applications | <https://docs.aws.amazon.com/appstream2/latest/developerguide/what-is-appstream.html> |
| `t3-8.md` | Amazon MQ | <https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/welcome.html> |
| `t3-5.md` | VPC Flow Logs | <https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html> |
| `t3-5.md` | PrivateLink | <https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html> |

## 4. Phase 0 — 드래프트 가드 보강

목표: q16+가 `verified:false`라 런타임에서 빠지더라도 raw JSON 품질을 검사한다.

권장 작업:

- `flutter_app/test/clf_supplement_questions_test.dart`를 새로 만든다.
- 검사 대상은 이번 보강 Task 7개만 둔다.
- `saa_questions_test.dart`의 조건을 이식한다: 중복 id 없음, options 4개, correct 0~3, wrongExplanations 키가 정답 제외 3개 전부, sources title/url 존재, section이 있으면 문자열 비어 있지 않음.
- section 앵커 존재성은 기존 `section_anchor_link_test.dart`가 전 CLF 질문을 검사하므로 중복 구현하지 않는다.

이 가드를 추가하지 않기로 결정하면, 문항 초안 커밋 전 동일 조건을 PowerShell/Node 스크립트로 실행하고 결과를 PR 본문에 붙인다.

## 5. Phase 1 — 학습문서 보강

공통 편집 규칙:

- 새 보강 헤딩은 `## 📖 핵심 개념` 안에 `### `로 둔다.
- 세부 서비스 설명은 `#### `를 써도 된다. `content_enrichment_test.dart`는 `^### `만 원리 하한 카운트에 사용한다.
- 원리 블록은 4~7줄, 단일 메커니즘만 설명한다.
- "AWS가 알아서 완벽히 보장한다" 같은 단정 금지. "가능하게 한다", "줄인다", "운영 부담을 낮춘다"처럼 보수적으로 쓴다.
- 함정 포인터는 기존 형식 `   *(원리: §N — ...)*`를 따른다.
- 문서 보강 초안 커밋에서는 `lastVerified`를 바꾸지 않는다.

문서별 배치:

| Lane | 파일 | 추가 앵커 | 보강 내용 | 문항 초안 |
|---|---|---|---|---|
| A | `t3-1.md` | `deployment-ops-tools` | Beanstalk, CDK, Systems Manager, CodeBuild/CodeDeploy/CodePipeline/CodeCommit 비교. CloudFormation과 역할 차이 중심 | +5 |
| B | `t2-3.md` | `app-directory-identity` | Cognito User Pool vs Identity Pool, Directory Service 옵션, IAM/Identity Center와 경계 | +3 |
| C | `t3-7.md` | `applied-ai-services` | Rekognition, Comprehend, Textract, Personalize, Forecast 레거시 주석. SageMaker와 경계 | +4 |
| B | `t2-2.md` | `certificates-hsm` | ACM, CloudHSM, KMS와의 차이. 인증서 관리 vs 키 관리 vs 전용 HSM | +3 |
| D | `t3-3.md` | `registry-batch` | ECR, AWS Batch. 컨테이너 실행 서비스와 저장소·배치 오케스트레이션 경계 | +2 |
| D | `t3-8.md` | `appstream-mq` | AppStream 2.0(현재 WorkSpaces Applications), Amazon MQ. WorkSpaces·SQS/SNS/EventBridge와 경계 | +2 |
| D | `t3-5.md` | `flow-logs-privatelink` | VPC Flow Logs, PrivateLink. 모니터링 로그 vs 사설 연결 경계 | +2 |

문서별 최소 산출물:

- 보강 `###` 섹션 1개 이상.
- 섹션 안에 비교표 1개 또는 시나리오 매핑표 1개.
- `> 🧠 원리:` 블록 1개 이상.
- `## ✍️ 시험 포인트`에 보강 주제 1~3줄 추가.
- `## ⚠️ 흔한 함정`에 보강 주제 기반 함정 1개 이상.
- `### 📌 출처 (verified)`에 공식 출처 추가.

Phase 1 검증:

```powershell
cd flutter_app
flutter test test/content_enrichment_test.dart test/all_content_parse_test.dart test/section_anchor_link_test.dart
```

## 6. Phase 2 — 문항 초안 21개

문항 작성 순서:

1. 보강된 문서 전체를 읽는다.
2. 기존 15문항과 자가점검 Q를 읽고 소재·정답 포인트 중복을 표시한다.
3. `q16`부터 새 문항을 배열 끝에 추가한다.
4. 모든 신규 문항은 `verified:false`다.
5. `section`은 Phase 1에서 추가한 새 앵커를 가리킨다.
6. `sources`는 해당 보강 문서에 추가한 공식 출처 범위에서만 고른다.

문항 배분:

| 파일 | 신규 id | 출제 각도 |
|---|---|---|
| `t3-1.questions.json` | `clf-t3-1-q16`~`q20` | Beanstalk vs CloudFormation, CDK와 CloudFormation 관계, Systems Manager 운영 작업, CodeBuild/Deploy/Pipeline 역할, CodeCommit 위치 |
| `t2-3.questions.json` | `clf-t2-3-q16`~`q18` | User Pool vs Identity Pool, Directory Service 선택, Cognito vs IAM Identity Center |
| `t3-7.questions.json` | `clf-t3-7-q16`~`q19` | 이미지/영상 분석, 문서 텍스트 추출, 자연어 인사이트, 추천 개인화. Forecast는 레거시 주석 때문에 기본 문항 제외 |
| `t2-2.questions.json` | `clf-t2-2-q16`~`q18` | ACM 인증서, CloudHSM vs KMS, CloudFront 인증서 리전 함정은 문서에 넣은 경우에만 |
| `t3-3.questions.json` | `clf-t3-3-q16`~`q17` | ECR은 이미지 저장소, Batch는 배치 작업 실행·스케줄링 |
| `t3-8.questions.json` | `clf-t3-8-q16`~`q17` | Amazon MQ vs SQS/SNS/EventBridge, AppStream/WorkSpaces Applications vs WorkSpaces |
| `t3-5.questions.json` | `clf-t3-5-q16`~`q17` | Flow Logs의 관측성, PrivateLink의 사설 연결 |

난이도 가이드:

- 핵심 4문서(t3-1, t2-3, t3-7, t2-2)는 applied 60% 이상.
- 소소 3문서(t3-3, t3-8, t3-5)는 foundational 1 + applied 1 구성이 기본.
- Forecast는 문서 보강에는 포함하되, 신규 고객 제한 때문에 별도 정답 문항으로 만들지 않는다. 출제해야 한다면 "레거시 서비스 상태"까지 문서와 출처에 명시한 경우에만 검수 게이트로 올린다.

Phase 2 검증:

```powershell
cd flutter_app
flutter test test/clf_supplement_questions_test.dart test/section_anchor_link_test.dart test/question_model_test.dart
```

`clf_supplement_questions_test.dart`를 만들지 않은 경우, raw JSON 검사 스크립트 결과를 대신 남기고 전체 테스트를 실행한다.

## 7. Phase 3 — AI 리뷰 + 사람 검수 산출물

AI 리뷰어는 아래 항목을 전수 검사하고 직접 수정한다.

- 공식 출처 대조: 문서와 문항의 사실이 seed 출처 또는 공식 하위 문서에 있는가.
- 범위: CLF 수준을 넘는 내부 구현·SAA급 세부 설정을 넣지 않았는가.
- 중복: 기존 15문항·자가점검과 같은 정답 포인트를 반복하지 않았는가.
- 해설: 정답 해설은 "왜 맞는지", 오답 해설은 "어떤 혼동을 노렸는지"를 말하는가.
- 앵커: `section`이 실제 `{#id}`에 존재하는가.
- 서비스 상태: Forecast와 AppStream/WorkSpaces Applications 명칭 주석이 누락되지 않았는가.

사람 검수용 산출물:

- 위치: `D:\workspace\clf-c02-supplement-qdrafts_for_review.json`
- 내용: 신규 문항만 추출한다.
- 문항별로 다음 필드를 포함한다: `id`, `task`, `section`, `stem`, `options`, `correct`, `explanation`, `wrongExplanations`, `sources`, `docEvidence`, `reviewNotes`.
- `docEvidence`는 "문서 파일 + 섹션 앵커 + 한 줄 근거" 형식으로 적는다.

STOP:

- 이 파일을 만든 뒤 사람 검수 전에는 `verified:true`로 바꾸지 않는다.
- 사람 피드백이 오면 문항·문서 수정 후 승인 문항만 flip한다.

## 8. Phase 4 — 검수 반영과 카운트 동기화

사람 검수 후:

1. 승인 문항만 `verified:true`로 바꾼다.
2. 반려 문항은 `verified:false`로 남기거나 삭제한다. 삭제하면 id 재사용 금지 여부를 검수 기록에 남긴다.
3. 보강 문서 `lastVerified`를 실제 검수일로 갱신한다.
4. `flutter_app/lib/data/content_index.dart`에서 각 Task `questionCount`를 실제 verified 수로 갱신한다.
5. README의 CLF 문항 수가 아직 228/12문항으로 남아 있으므로, 이 작업 범위에 포함하려면 최종 verified 합계로 함께 갱신한다. 별도 PR로 미룬다면 PR 본문에 "README 문항 수 갱신 별도"를 명시한다.

검증:

```powershell
cd flutter_app
flutter test
flutter analyze
```

예상 카운트(21개 전부 승인 시):

| Task | 기존 verified | 승인 후 |
|---|---:|---:|
| `clf-t3-1` | 15 | 20 |
| `clf-t2-3` | 15 | 18 |
| `clf-t3-7` | 15 | 19 |
| `clf-t2-2` | 15 | 18 |
| `clf-t3-3` | 15 | 17 |
| `clf-t3-8` | 15 | 17 |
| `clf-t3-5` | 15 | 17 |
| CLF 전체 | 285 | 306 |

18~20개만 승인되면 해당 수에 맞춰 동적으로 갱신한다. `content_index_test.dart`의 동적 불변식이 최종 판정자다.

## 9. 커밋 단위

권장 커밋:

1. `test(content): add CLF supplement draft question guard`
2. `docs(content): supplement CLF-C02 study docs from official sources`
3. `feat(content): draft CLF-C02 supplement questions`
4. `fix(content): address CLF supplement question review`
5. `chore(content): verify CLF supplement questions and sync counts`

각 커밋은 선택적 스테이징만 한다.

```powershell
git add flutter_app/assets/content/clf/t3-1.md flutter_app/assets/content/clf/t2-3.md
git diff --cached --check
git commit -m "docs(content): supplement CLF-C02 study docs from official sources"
```

## 10. 완료 정의

- 보강 주제 7개가 문서에 반영됐다.
- 공식 출처 URL이 문서와 문항에 남아 있다.
- 신규 문항은 사람 검수 전 `verified:false`, 검수 후 승인분만 `verified:true`다.
- `content_index.dart` questionCount와 JSON verified 수가 일치한다.
- `flutter test` 전체 통과.
- `flutter analyze` 신규 경고 0.
- PR 본문에 다음을 포함한다: 보강 문서 목록, 신규 문항 수, 검수 산출물 위치, Forecast/AppStream 명칭 처리, 테스트 결과.
