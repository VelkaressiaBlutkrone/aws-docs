# CLF-C02 콘텐츠 표적 보충 — 작업 내용 정리

작성일: 2026-06-21
브랜치: `codex/clf-c02-content-supplement`
상태: **사람 검수 대기(STOP 지점)** — 문서 보강과 `verified:false` 문항 초안 작성 완료

원문:

- 설계 스펙: `docs/superpowers/specs/2026-06-20-clf-c02-content-supplement-design.md`
- 실행 플랜: `docs/superpowers/plans/2026-06-20-clf-c02-content-supplement.md`

## 1. 작업 범위

기존 CLF-C02 19개 Task 구조는 유지하고, 아래 7개 기존 문서에 인플레이스 보강을 적용했다. 새 Task는 만들지 않았다.

| Task 문서 | 추가 앵커 | 보강 주제 |
|---|---|---|
| `flutter_app/assets/content/clf/t3-1.md` | `deployment-ops-tools` | Elastic Beanstalk, AWS CDK, Systems Manager, CodePipeline, CodeBuild, CodeDeploy, CodeCommit |
| `flutter_app/assets/content/clf/t2-3.md` | `app-directory-identity` | Amazon Cognito User Pool/Identity Pool, AWS Directory Service, IAM/Identity Center와의 경계 |
| `flutter_app/assets/content/clf/t3-7.md` | `applied-ai-services` | Rekognition, Comprehend, Textract, Personalize, Forecast 레거시 주석 |
| `flutter_app/assets/content/clf/t2-2.md` | `certificates-hsm` | ACM, CloudHSM, KMS와의 차이, CloudFront용 ACM 인증서 리전 |
| `flutter_app/assets/content/clf/t3-3.md` | `registry-batch` | Amazon ECR, AWS Batch |
| `flutter_app/assets/content/clf/t3-8.md` | `appstream-mq` | AppStream 2.0 / Amazon WorkSpaces Applications, Amazon MQ |
| `flutter_app/assets/content/clf/t3-5.md` | `flow-logs-privatelink` | VPC Flow Logs, AWS PrivateLink |

공통으로 각 문서에 다음을 반영했다.

- `## 📖 핵심 개념` 안에 `###` 보강 섹션 추가
- 비교표 또는 시나리오 매핑표 추가
- `> 🧠 원리:` 블록 추가
- `## ✍️ 시험 포인트` 보강
- `## ⚠️ 흔한 함정` 보강
- frontmatter `sources`와 `### 📌 출처 (verified)`에 공식 AWS 출처 추가

## 2. 문항 초안

신규 문항 21개를 각 `.questions.json` 배열 끝에 추가했다. 모두 사람 검수 전 상태이므로 `verified:false`다.

| 문항 파일 | 신규 id | 개수 |
|---|---|---:|
| `t3-1.questions.json` | `clf-t3-1-q16` ~ `q20` | 5 |
| `t2-3.questions.json` | `clf-t2-3-q16` ~ `q18` | 3 |
| `t3-7.questions.json` | `clf-t3-7-q16` ~ `q19` | 4 |
| `t2-2.questions.json` | `clf-t2-2-q16` ~ `q18` | 3 |
| `t3-3.questions.json` | `clf-t3-3-q16` ~ `q17` | 2 |
| `t3-8.questions.json` | `clf-t3-8-q16` ~ `q17` | 2 |
| `t3-5.questions.json` | `clf-t3-5-q16` ~ `q17` | 2 |

중요 처리:

- Forecast는 공식 문서상 신규 고객에게 더 이상 제공되지 않으므로 문서에는 레거시 상태를 명시했고, 신규 문항의 정답 서비스로는 쓰지 않았다.
- AppStream 2.0은 현재 공식 문서 제목인 `Amazon WorkSpaces Applications`를 함께 병기했다.
- `section`은 모두 이번에 추가한 새 앵커를 가리킨다.
- `content_index.dart`, README 문항 수, 문서 `lastVerified`는 아직 수정하지 않았다.

## 3. 추가한 테스트 가드

새 파일:

- `flutter_app/test/clf_supplement_questions_test.dart`

역할:

- 이번 보강 대상 7개 CLF raw question JSON을 직접 파싱한다.
- `verified:false` 문항이 런타임 풀에서 제외되더라도 초안 단계의 구조 품질을 검사한다.
- 중복 id, 보기 4개, `correct` 범위, 비정답 3개 전부의 `wrongExplanations`, 출처 title/url, 빈 `section`을 검증한다.

## 4. 검수용 산출물

사람 검수용 신규 문항 추출 파일을 생성했다.

- `D:\workspace\clf-c02-supplement-qdrafts_for_review.json`
- 포함 개수: 21개
- 포함 필드: `id`, `task`, `section`, `stem`, `options`, `correct`, `explanation`, `wrongExplanations`, `sources`, `docEvidence`, `reviewNotes`

이 파일을 기준으로 사람 검수 후 승인 문항만 `verified:true`로 전환한다.

## 5. 검증 결과

실행한 테스트:

```powershell
flutter test test/clf_supplement_questions_test.dart
flutter test test/content_enrichment_test.dart test/all_content_parse_test.dart test/section_anchor_link_test.dart
flutter test test/clf_supplement_questions_test.dart test/section_anchor_link_test.dart test/question_model_test.dart
flutter test
git diff --check
flutter analyze --no-pub
```

결과:

- `flutter test`: 통과
- `git diff --check`: 공백 오류 없음
- `flutter analyze --no-pub`: 기존 3건만 보고, 이번 변경 파일 관련 신규 이슈 없음

분석 기존 이슈:

- `lib/pages/plan/plan_agenda.dart:226` — deprecated `cacheExtent`
- `test/cloud/sync_controller_test.dart:4` — `fake_async` dependency 경고
- `test/cloud/sync_controller_test.dart:51` — optional parameter `onAppResume` unused 경고

## 6. 아직 하지 않은 일

사람 검수 전에는 아래 작업을 하지 않는다.

- 신규 문항 `verified:true` 전환
- `flutter_app/lib/data/content_index.dart`의 `questionCount` 갱신
- README의 CLF 전체 문항 수 갱신
- 보강 문서 `lastVerified` 갱신

## 7. 다음 단계

1. `D:\workspace\clf-c02-supplement-qdrafts_for_review.json`으로 21개 문항을 사람 검수한다.
2. 승인 문항만 `verified:true`로 전환한다.
3. 문서 `lastVerified`를 실제 검수일로 갱신한다.
4. `content_index.dart`의 각 Task `questionCount`를 실제 verified 수와 맞춘다.
5. README 문항 수를 최종 verified 합계로 갱신한다.
6. `flutter test`와 `flutter analyze`를 다시 실행한다.

