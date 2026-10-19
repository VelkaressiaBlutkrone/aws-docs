# DVA-C02 — 시험 개요 · 공식 가이드 메타 · 레포 대조

> **원자료 노트(저작 재료)** · 조회일 **2026-10-17** · 사실마다 URL을 붙였다. 확인하지 못한 것은 본문에 쓰지 않고 `99-gaps.md`에 남겼다.
> 이 폴더(`docs/content-research/DVA-C02/`) 밖은 읽기만 했다. 학습문서·문항 저작과 `content_index.dart` 등록은 하지 않았다(취합 세션 몫).
> 인용은 공식 원문(영문)을 15단어 이내로만 옮겼다. 설명·정리는 본인 말(한국어)이다.

---

## 0. ⚠️ 먼저 알아야 할 것 — DVA-C02는 곧 종료되고 DVA-C03로 교체된다

| 항목 | 확인된 내용 | 출처 인용(≤15단어) | URL |
|---|---|---|---|
| DVA-C03 등록 시작 | 2026-10-27 (모든 언어) | "Registration for the updated exam (DVA-C03) will open on October 27, 2026" | https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ |
| DVA-C03 응시(GA) 시작 | 2026-12-01 | "GA delivery beginning December 1, 2026" | 위와 동일 |
| DVA-C02 마지막 응시일 | 2026-11-30 (영문 인증 페이지·공식 블로그) | "The last day to take the current exam (DVA-C02) is November 30, 2026." | https://aws.amazon.com/certification/certified-developer-associate/ |
| (표기 차이) | **한국어 인증 페이지는 "2026년 12월 1일"로 표기** — 영문과 하루 다름 | "현재 시험(DVA-C02)에 응시할 수 있는 마지막 날은 2026년 12월 1일입니다." | https://aws.amazon.com/ko/certification/certified-developer-associate/ |
| DVA-C03 공식 시험 가이드 | **아직 없음**(2026-10-17 시점). 블로그: 가이드는 등록 시작일(10-27)에 공개 예정 | "The full exam guide with detailed task statements will be available when registration opens" | 블로그(위) |
| 문서 사이트의 C03 URL | `.../aws-certification/latest/developer-associate-03/developer-associate-03.html` → `not_found` (조회 2026-10-17) | (도구 응답 `not_found`) | https://docs.aws.amazon.com/aws-certification/latest/developer-associate-03/developer-associate-03.html |
| 기존 자격 | DVA-C02로 취득한 자격은 원래 만료일까지 유효 | "Your credential remains active through its original expiration date." | 블로그(위) |

### 블로그가 밝힌 DVA-C03 변경 요약 (가이드 공개 전 — 공식 블로그 요약만 근거)

출처: https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ (조회 2026-10-17)

- **신규 Task 2.3 「AI security」(5 skills)**: AI 서비스 접근 관리, 데이터 프라이버시 제어(VPC 엔드포인트, 입출력이 모델 학습에 쓰이지 않도록), 콘텐츠 필터링·프롬프트 인젝션 방어, AI 에이전트 상호작용 보안(도구 사용 권한·세션 격리·사람 승인 흐름), 모니터링 로그의 민감 콘텐츠 보호.
- **AI 보조 개발이 전 도메인에 스며듦**: 코드 생성·자동 리뷰(도메인 1), 테스트 자동화·회귀 테스트(도메인 3), CI/CD 지원(배포 승인 자동화 등, 도메인 3), 오류 분석·문제 해결 제안, 성능 최적화 권고(도메인 4).
- **컨테이너 관리**: ECR 이미지 빌드·관리, ECS·EKS·Fargate 배포.
- **in-scope 서비스 신규**: Amazon Bedrock, Amazon Bedrock AgentCore, Amazon Q, Kiro, Amazon Data Firehose, AWS PrivateLink.
- **통합(consolidation)**: DynamoDB 4개 skill→1개 / 암호화·민감 데이터 13개 skill(2 task)→7개 skill(1 task) / 테스트 11개 skill(2 task)→5개 skill(1 task) / 관찰성 8→5 / 최적화 9→6.
- **도메인 비중(블로그)**: 1 Development with AWS Services 30% · 2 Security 26% · **3 Testing and Deployment 22%** · 4 Troubleshooting and Optimization 22%. (C02는 32/26/24/18)
- **범위 밖(블로그)**: Prompt engineering, RAG design, AI model selection, Amazon SageMaker AI, AI governance framework design.
- **시험 형식은 동일**: 130분, 65문항(채점 50 + 비채점 15), 150 USD, 합격 720/1,000.
- C02 → C03 skill 단위 대응 관계는 가이드 공개 후에야 확인 가능 → `99-gaps.md` G-01.

> 이 노트는 **현행 가이드 v2.1(DVA-C02)** 기준이다. C03 가이드가 10-27에 공개되면 Task/Skill 대조를 한 번 더 해야 한다.

---

## 1. 시험 메타 (공식 실측)

| 항목 | 값 | 출처 인용(≤15단어) | URL |
|---|---|---|---|
| 공식 자격증명 | AWS Certified Developer - Associate | (페이지 제목) "AWS Certified Developer - Associate" | https://aws.amazon.com/certification/certified-developer-associate/ |
| 시험 코드 | DVA-C02 | "AWS Certified Developer - Associate (DVA-C02)" | https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/developer-associate-02.html |
| 레벨(카테고리) | Associate | (페이지 항목 Category: Associate) | https://aws.amazon.com/certification/certified-developer-associate/ |
| 대상 경력 | AWS 서비스로 애플리케이션을 개발·유지한 실무 1년 이상 | "1 or more years of hands-on experience" | https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/developer-associate-02.html |
| 시험 시간 | 130분 | "You will have 130 minutes to complete your exam." | https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/developer-associate-02.html |
| 총 문항 수 | 65 | "65 questions; either multiple choice or multiple response" | https://aws.amazon.com/certification/certified-developer-associate/ |
| 채점 문항 | 50 | "The exam includes 50 questions that affect your score." | https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/developer-associate-02.html |
| 비채점 문항 | 15 (시험 중 식별 불가) | "The exam includes 15 unscored questions that do not affect your score." | 위와 동일 |
| 문항 유형 | ① multiple choice: 정답 1 + 오답 3 ② multiple response: 5개 이상 보기 중 정답 2개 이상 | "Has two or more correct responses out of five or more response options" | 위와 동일 |
| 오답 처리 | 미응답=오답, 감점 없음 | "Unanswered questions are scored as incorrect; there is no penalty for guessing." | 위와 동일 |
| 점수 체계 | 100–1,000 환산점수, **합격 720**, 보상(compensatory) 모델(영역별 합격선 없음) | "The minimum passing score is 720." / "The exam uses a compensatory scoring model" | 위와 동일 |
| 응시료 | 150 USD | "150 USD." | https://aws.amazon.com/certification/certified-developer-associate/ |
| 응시 방식 | Pearson VUE 시험장 또는 온라인 감독 | "Pearson VUE testing center or online proctored exam" | 위와 동일 |
| 제공 언어 | 영어·일본어·한국어·포르투갈어(브라질)·중국어 간체·스페인어(중남미) | "English, Japanese, Korean, Portuguese (Brazil), Simplified Chinese, and Spanish (Latin America)." | 위와 동일 |
| 자격 유효기간 | 3년. 재인증은 최신 시험 합격 또는 DevOps Engineer - Professional 취득 | "This certification is valid for 3 years." | 위와 동일 |
| 가이드 개정 공지 규칙 | 개정은 시험 반영 최소 1개월 전에 게시 | "Exam guide revisions will be published at least one month before changes" | https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/developer-associate-02.html |

> **레포 앱과의 관계**: 이 사이트의 문항 스키마는 보기 4개·정답 1개(`phase3-content-handoff.md` §3.3)인데, 실제 시험에는 **multiple response(정답 2개 이상)** 유형이 있다. 노트의 문항 후보는 모두 4지선다 1정답으로 썼다(앱 스키마 기준).

---

## 2. 도메인·비중·Task·Skill 구성 (공식 가이드 v2.1)

출처(EN): https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/developer-associate-02.html (비중), `.../developer-associate-02-domain1.html` ~ `-domain4.html` (Task/Skill) — 조회 2026-10-17

| 도메인 | 이름(EN / KO) | 비중 | Task | Skill 수 | 🆕 신규 Skill | 산술 환산 채점 문항* |
|---|---|---|---|---|---|---|
| 1 | Development with AWS Services / AWS 서비스를 통한 개발 | 32% | 1.1, 1.2, 1.3 | 13+7+9 = **29** | 5 | ≈16 |
| 2 | Security / 보안 | 26% | 2.1, 2.2, 2.3 | 8+7+6 = **21** | 4 | ≈13 |
| 3 | Deployment / 배포 | 24% | 3.1, 3.2, 3.3, 3.4 | 5+5+6+11 = **27** | 3 | ≈12 |
| 4 | Troubleshooting and Optimization / 문제 해결 및 최적화 | 18% | 4.1, 4.2, 4.3 | 7+8+9 = **24** | 6 | ≈9 |
| 합계 | | 100% | **13 Task** | **101 Skill** | 18 | 50 |

\* 채점 50문항 × 공식 비중의 **단순 산술 환산**이다. 공식 문항 수가 아니며, 비채점 15문항의 도메인 배분과 Task별 비중은 공개되지 않았다. 인용: "Content Domain 1: Development with AWS Services (32% of scored content)".

### Task 목록 (공식 표기 "Task N of Domain M" ↔ 레포·노트 표기 M.N)

| 노트 파일 | Task (EN) | Task (KO) | Skill 수 | 🆕 |
|---|---|---|---|---|
| tasks/1-1.md | Develop code for applications hosted on AWS | AWS에서 호스팅되는 애플리케이션 코드 개발 | 13 | 1.1.11·1.1.12·1.1.13 |
| tasks/1-2.md | Develop code for AWS Lambda | AWS Lambda용 개발 코드 | 7 | 1.2.7 |
| tasks/1-3.md | Use data stores in application development | 애플리케이션 개발 시 데이터 스토어 사용 | 9 | 1.3.9 |
| tasks/2-1.md | Implement authentication and/or authorization for applications and AWS services | 애플리케이션 및 AWS 서비스에 대한 인증 또는 권한 부여 구현 | 8 | 2.1.7·2.1.8 |
| tasks/2-2.md | Implement encryption by using AWS services | AWS 서비스를 사용하여 암호화 구현 | 7 | — |
| tasks/2-3.md | Manage sensitive data in application code | 애플리케이션 코드에서 민감한 데이터 관리 | 6 | 2.3.5·2.3.6 |
| tasks/3-1.md | Prepare application artifacts to be deployed to AWS | AWS에 배포할 애플리케이션 아티팩트 준비 | 5 | 3.1.5 |
| tasks/3-2.md | Test applications in development environments | 개발 환경에서 애플리케이션 테스트 | 5 | 3.2.5 (3.2.2는 ✏️ 표현 변경) |
| tasks/3-3.md | Automate deployment testing | 배포 테스트 자동화 | 6 | 3.3.6 |
| tasks/3-4.md | Deploy code by using AWS Continuous Integration and Continuous Delivery (CI/CD) services | AWS 지속적 통합 및 지속적 전달(CI/CD) 서비스로 코드 배포 | 11 | — (3.4.11은 ✏️) |
| tasks/4-1.md | Assist in a root cause analysis | 근본 원인 분석 지원 | 7 | 4.1.7 |
| tasks/4-2.md | Instrument code for observability | 코드 계측을 통해 관찰성 향상 | 8 | 4.2.8 (4.2.7은 ✏️) |
| tasks/4-3.md | Optimize applications by using AWS services and features | AWS 서비스 및 기능을 사용하여 애플리케이션 최적화 | 9 | 4.3.6·4.3.7·4.3.8·4.3.9 |

- 한국어 가이드의 용어: Task=**작업**, Skill=**기술**, Domain=**콘텐츠 도메인**. v2.1부터 Knowledge 항목이 없고 Skill 목록 하나로 통합됐다(레포 JSON의 `knowledge: []`는 이에 부합).
- 각 Task 노트 상단에 공식 Skill 원문(EN+KO) 표를 넣었다. **🆕 = v2.1 신규 18개**, **✏️ = v2.0→v2.1 표현 변경 3개(3.2.2·3.4.11·4.2.7)**.

---

## 3. 공식 가이드 버전·개정 상태

| 항목 | 내용 | 출처 인용 / URL |
|---|---|---|
| 현행 버전 | **v2.1 — 2024-12-12** | 개정 표 "2.1 \| December 12, 2024" — https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/dva-02-revisions.html |
| 이전 버전 | v2.0 — 게시일 칸이 **공란** | 개정 표 "2.0 \| " (날짜 없음) — 위와 동일 |
| 한국어 가이드 개정 표 | "2.1 \| 2024년 12월 12일" (영문과 동일) | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-02/dva-02-revisions.html |
| v2.1 변경의 성격 | v2.0의 Knowledge/Skill을 Task별 Skill 한 목록으로 통합. Skill과 겹치는 Knowledge는 삭제 | "consolidated into one list of skills under each task" |
| 신규 Skill | 18개 (§2 표의 🆕) | 같은 페이지 "New skills added" |
| 표현 변경 | 3.2.2(통합 테스트·모의 API), 3.4.11(배포 전략 구성), 4.2.7(구조화된 로깅) | 같은 페이지 "Changes to knowledge and skills" |
| 삭제된 Skill | 없음 (이미 Skill에 포함된 Knowledge 항목만 삭제) | "There are no knowledge and skills removed" |
| in-scope 목록 추가 | Amazon Q Developer | "Services added to the in-scope list" |
| in-scope 목록 제거 | AWS Copilot, Amazon CodeGuru | "Services removed from the in-scope list" |
| out-of-scope 목록 제거 | AWS Device Farm, Amazon Lex, AWS Service Catalog, AWS DMS | "Services removed from the out-of-scope list" |
| 문서 사이트상 최신 개정 표 | v2.1이 맨 위(최신) — 이후 버전 행 없음 | 위 개정 페이지 (조회 2026-10-17) |
| DVA-C02 최초 시행 | 2023-02-28 | "The first day to take the updated AWS Certified Developer – Associate exam is February 28, 2023." — https://aws.amazon.com/blogs/training-and-certification/updated-aws-certified-developer-associate-registration-now-open/ |
| C01→C02 때 바뀐 것 | 도메인 4 "Refactoring" 해체·재배분, Task 1.3·2.3·3.2·3.3 추가, Elastic Beanstalk 배포 Task 삭제 | "Domain 1: Task 1.3 Utilize data stores in application development" (같은 블로그) |

> ⚠️ **Emerging topics 섹션**: 현재 영문·한국어 가이드 소개 페이지에는 "Emerging topics / 새로운 주제" 절(AI 보조 개발 등, 사전 테스트=**비채점** 문항 대상)이 있지만, 개정 표(v2.1, 2024-12-12)에는 이 절의 추가가 기록돼 있지 않다. 추가 시점은 공식 확인 불가 → `99-gaps.md` G-04.
> 인용: "These topics represent evolving areas of competence and might appear as pretest questions" — https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/developer-associate-02.html
> Emerging topics의 6개 항목(요약): AI 보조 개발 도구로 코드 생성·리뷰·최적화 / AI 서비스 통합 시 보안 위험 식별·완화(로그에 민감 콘텐츠 방지 등) / AI 도구로 테스트 생성·자동화 / AI 도구로 CI/CD 지원 / AI 도구로 오류 분석·문제 해결 제안 / AI 도구로 최적화 기회 식별. 비채점이라 문항 은행의 필수 범위는 아니다.

### 공식 URL 목록 (모두 2026-10-17 조회)

| 구분 | URL |
|---|---|
| 가이드 소개 (EN) | https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/developer-associate-02.html |
| 가이드 소개 (KO) | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-02/developer-associate-02.html |
| 도메인 1~4 (EN) | `.../developer-associate-02/developer-associate-02-domain1.html` … `-domain4.html` |
| 도메인 1~4 (KO) | `.../ko_kr/aws-certification/latest/developer-associate-02/developer-associate-02-domain1.html` … `-domain4.html` |
| 개정 (EN / KO) | `.../developer-associate-02/dva-02-revisions.html` / `.../ko_kr/.../dva-02-revisions.html` |
| in-scope 서비스 | https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/dva-02-in-scope-services.html |
| out-of-scope 서비스 | https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/dva-02-out-of-scope-services.html |
| 기술 및 개념 | https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/dva-technologies-concepts.html |
| 시험에서 언급되는 서비스명(약칭) | https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/dva-service-mentions.html |
| 공식 PDF (검색 결과에서 URL 확인, **본문 미열람**) | https://docs.aws.amazon.com/pdfs/aws-certification/latest/developer-associate-02/developer-associate-02.pdf |
| 인증 페이지 (EN / KO) | https://aws.amazon.com/certification/certified-developer-associate/ / https://aws.amazon.com/ko/certification/certified-developer-associate/ |
| 공식 시험 준비 플랜(Skill Builder, KO 인증 페이지의 링크) | https://skillbuilder.aws/category/exam-prep/developer-associate-DVA-C02 |
| 2026-09 인증 업데이트 블로그(DVA-C03 예고) | https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ |
| 2023 DVA-C02 시행 블로그 | https://aws.amazon.com/blogs/training-and-certification/updated-aws-certified-developer-associate-registration-now-open/ |

---

## 4. 공식 자격증명·이름 변경 확인

- 공식명은 **"AWS Certified Developer - Associate"**(영문 가이드·인증 페이지). 블로그는 en dash(–)로 표기하는 등 하이픈 표기만 다르다. 코드 DVA-C02.
- 이름 변경은 확인되지 않았다. 2026-09 블로그도 후속 시험을 같은 이름 **"AWS Certified Developer – Associate (DVA-C03)"**로 부른다. 인용: "AWS Certified Developer – Associate (DVA-C03)". (출처: https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/)
- 참고: 영문 인증 페이지 FAQ의 '다음 자격증' 안내는 "AWS Certified SysOps Administrator - Associate"라는 옛 이름을 그대로 쓰고 있다(레포의 SOA-C03 표기와 다름). DVA 자체의 이름과는 무관한 공식 페이지 내부 표기 차이다. — https://aws.amazon.com/certification/certified-developer-associate/

---

## 5. 공식 가이드가 밝힌 대상 응시자·범위 밖 업무

출처: https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/developer-associate-02.html (조회 2026-10-17)

- 시험이 확인하는 능력(4가지): AWS 애플리케이션 개발·최적화 / CI/CD 워크플로로 패키징·배포 / 애플리케이션 코드·데이터 보호 / 애플리케이션 문제 식별·해결.
- 권장 일반 IT 지식: 고급 프로그래밍 언어 1개 이상, 애플리케이션 수명 주기 관리, 코드가 필요한 클라우드 애플리케이션 기본 이해, 기능하는 애플리케이션 개발 능력, 개발 도구 사용 경험.
- 권장 AWS 지식: AWS 서비스 API·AWS CLI·SDK로 애플리케이션 개발·보호, CI/CD 파이프라인으로 AWS에 배포.
- **시험 범위 밖 업무(5)**: ① 아키텍처 설계(분산 시스템·마이크로서비스·DB 스키마/모델링) ② CI/CD 파이프라인 **설계·생성** ③ IAM 사용자·그룹 **관리** ④ 서버·운영체제 관리 ⑤ AWS 네트워킹 인프라 설계(VPC, Direct Connect 등). 인용: "Design and create CI/CD pipelines."

---

## 6. 서비스 범위 (공식 목록 — "non-exhaustive and is subject to change")

출처: https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/dva-02-in-scope-services.html · https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/dva-02-out-of-scope-services.html (조회 2026-10-17)

### in-scope (47개, 카테고리별)

| 카테고리 | 서비스 |
|---|---|
| Analytics | Amazon Athena · Amazon Kinesis · Amazon OpenSearch Service |
| Application Integration | AWS AppSync · Amazon EventBridge · Amazon SNS · Amazon SQS · AWS Step Functions |
| Compute | Amazon EC2 · AWS Elastic Beanstalk · AWS Lambda |
| Containers | Amazon ECR · Amazon ECS · Amazon EKS |
| Database | Amazon Aurora · Amazon DynamoDB · Amazon ElastiCache · Amazon RDS |
| Developer Tools | AWS Amplify · AWS CloudShell · AWS CodeArtifact · AWS CodeBuild · AWS CodeDeploy · AWS CodePipeline · AWS X-Ray · Amazon Q Developer |
| Management and Governance | AWS AppConfig · AWS CDK · AWS CloudFormation · AWS CloudTrail · Amazon CloudWatch · AWS CLI · AWS Systems Manager |
| Networking and Content Delivery | Amazon API Gateway · Amazon CloudFront · Elastic Load Balancing · Amazon Route 53 · Amazon VPC |
| Security, Identity, and Compliance | Amazon Cognito · AWS IAM · AWS KMS · AWS Secrets Manager · AWS STS · AWS WAF |
| Storage | Amazon EBS · Amazon EFS · Amazon S3 |

### out-of-scope (명시)

Amazon Quick Sight · Amazon Chime · Amazon Connect · Amazon WorkMail · Amazon AppStream 2.0 · Amazon WorkSpaces · Amazon GameLift · Amazon Polly · Amazon Rekognition · AWS Managed Services (AMS) · Amazon Elastic Transcoder · AWS Application Discovery Service · AWS Application Migration Service · AWS Shield Advanced/Standard · AWS Snow Family · AWS Storage Gateway

### 기술 및 개념 카테고리 (순서·배치는 중요도와 무관 — 공식 주석)

Analytics · Application integration · Compute · Containers · Cost and capacity management · Database · Developer tools · Management and governance · Networking and content delivery · Security, identity, and compliance · Storage — https://docs.aws.amazon.com/aws-certification/latest/developer-associate-02/dva-technologies-concepts.html

### Skill 문구에는 나오지만 in-scope 목록에는 없는 서비스 (공식 가이드 내부 불일치)

| Skill | 문구 속 서비스 | in-scope 목록 | 비고 |
|---|---|---|---|
| 1.1.7·3.2.4·3.3.1·3.3.4·3.4.3 | AWS SAM | **없음** | 목록은 non-exhaustive. Task 노트에서는 문구 기준으로 다룸 |
| 2.2.2 | AWS Private CA | **없음** | 같음 |
| 3.3.3 | AWS Copilot 환경 | **v2.1에서 목록 제거** | 문구 예시는 그대로 남음 → 현재 서비스 상태 확인 필요(Task 3.3 노트 `확인 필요`) |
| 4.3.2 | (Profile application performance) | CodeGuru **v2.1에서 목록 제거** | 프로파일링 전용 서비스가 목록에 없음 |
| 3.4.6 | "repository" (CodeCommit 미명시) | CodeCommit은 in/out-of-scope 어느 목록에도 없음 | 저장소 서비스 상태는 Task 3.1·3.4 노트 참조 |

---

## 7. 레포 `DVA-C02.json` · 사이트 메타 ↔ 공식 페이지 대조

대조 대상: `flutter_app/assets/exam_guides/DVA-C02.json`, `flutter_app/assets/exam_summaries.json`, `flutter_app/lib/data/site_data.dart`, `flutter_app/web/index.html`, `docs/plans/2026-06-09-assets-official-audit.md`.

### 7.1 일치 확인 (이상 없음)

- **Skill 101개 문구**: JSON의 `skills[]` 한국어 문구를 공식 ko_kr 도메인 1~4 페이지와 대조(스크립트로 노트의 한국어 Skill 표와 비교) → **불일치 0건**. Task 13개 제목·도메인 4개 이름·비중 32/26/24/18·`passingScore` 720·`scoredQuestions` 50·`unscoredQuestions` 15·`durationMinutes` 130·`level` Associate 모두 공식 값과 일치. `slug`(`developer-associate-02`)도 공식 URL 슬러그와 같다.
- `sourceUrl`은 공식 ko_kr 가이드 소개 페이지로 유효(조회 성공).
- 이전 감사(`docs/plans/2026-06-09-assets-official-audit.md` 75행)의 DVA-C02 행(720 / 50+15 / 32·26·24·18 / PASS)과도 일치.

### 7.2 불일치·결손 목록

| # | 항목 | 레포 | 공식 | 영향 | 제안 |
|---|---|---|---|---|---|
| M-1 | **가이드 버전·게시일** | JSON에 필드 없음 | v2.1 · 2024-12-12 | 어느 개정판 기준인지 알 수 없음 | JSON에 버전 필드를 두려면 스키마·로더 영향 확인 필요(코드 변경은 이 작업 범위 밖). 최소한 노트·매핑 문서에 v2.1 명시 |
| M-2 | **Skill 번호(1.1.1 …)** | 없음(순서만) | 공식은 번호 부여 | 문항의 `skill` 필드에 번호를 쓰기 어려움 | 번호는 노트 상단 표를 기준으로 인용 |
| M-3 | **Skill 4.3.2 번역** | "애플리케이션 성능 최적화" | EN "Profile application performance"(프로파일링) | **한국어 공식 가이드 자체의 번역 불일치** — JSON은 ko 원문을 정확히 반영 | JSON은 유지. 학습문서에서는 '프로파일링'으로 다루고 근거(EN 원문) 병기 |
| M-4 | **`exam_summaries.json` outOfScope** | "분산 시스템 및 데이터베이스 모델링 등 아키텍처 설계"·"CI/CD 파이프라인 자체 설계 및 생성"·"서버/운영 체제 관리 및 네트워킹 인프라 설계" 3개 | 5개: 위 항목 + **IAM 사용자·그룹 관리** + 마이크로서비스 설계 명시 | 경미한 누락 | 요약에 "IAM 사용자 및 그룹 관리" 추가 검토 |
| M-5 | 한국어 가이드 내부 표기 | JSON 도메인 1 "AWS 서비스를 통한 개발"(도메인 페이지 제목과 일치) | ko 가이드 '내용 개요'는 "AWS 서비스를 사용한 개발" | 한국어 가이드 내부 불일치(레포 오류 아님) | 현행 유지 |
| M-6 | JSON에 없는 공식 정보 | — | 문항 유형(선다형·복수 응답형), 응시료·언어, in/out-of-scope 서비스, Emerging topics | 정보 결손(오류 아님) | 이 노트로 보완 |
| M-7 | **시한성** | 사이트·JSON·테스트가 `DVA-C02` 단일 코드 가정 | DVA-C03 GA 2026-12-01, C02 응시 마감 2026-11-30 | C03 공개 후 코드·가중치(30/26/22/22)·도메인 3 이름("Testing and Deployment")·Task 구성이 달라짐 | C03 가이드(10-27 공개 예정) 확인 후 JSON 개정 필요 여부 판단 |
| M-8 | **테스트가 DVA-C02를 '콘텐츠 없음' 예시로 사용** | `flutter_app/test/content_index_test.dart:10` `certHasContent('DVA-C02')` isFalse, `:34-37` `certContentSummary('DVA-C02')` 0, `flutter_app/test/home_sections_test.dart:31` "준비 중" 그룹에서 `find.text('DVA-C02')` | — | DVA-C02 콘텐츠를 `content_index.dart`에 등록하면 이 테스트들이 깨짐 | 등록 시 다른 미보유 자격증(예: DEA-C01·MLA-C01)을 예시로 교체(테스트 선수정) |
| M-9 | 사이트 메타의 코드 표기 | `site_data.dart:59`, `web/index.html:84,192`에 `DVA-C02` 하드코딩 | C03로 전환되면 코드·이름 표기 갱신 필요 | 시한성(M-7)과 연동 | 전환 시점에 일괄 갱신 |

### 7.3 공식 가이드 자체의 내부 불일치 (참고 — 저작 시 주의)

| # | 내용 | 근거 |
|---|---|---|
| I-1 | Skill 3.3.3 예시에 "AWS Copilot environments"가 있는데 v2.1 개정 표는 AWS Copilot을 in-scope에서 제거했다고 적음 | 도메인 3 페이지 vs 개정 페이지 |
| I-2 | Skill 1.2.7: 도메인 1 페이지는 "in near real time", 개정 페이지의 신규 Skill 목록은 "for real-time data processing" | 도메인 1 페이지 vs 개정 페이지 |
| I-3 | Skill 3.1.5(도메인 3 페이지 "for specific environments") vs 개정 페이지("for different environments"), Skill 2.1.8("microservice" vs "microservices") 등 사소한 어휘 차이 | 도메인 페이지 vs 개정 페이지 |
| I-4 | Skill 4.3.2: EN "Profile application performance" ↔ KO "애플리케이션 성능 최적화" | EN/KO 도메인 4 페이지 |
| I-5 | 서비스 목록은 "non-exhaustive"라 SAM·Private CA 등 Skill 문구의 서비스가 목록에 없음(§6) | in-scope 페이지 |

---

## 8. 한국어 가이드의 용어 선택 (저작 시 표기 통일용 참고)

출처: 공식 ko_kr 도메인 1~4 페이지 (조회 2026-10-17). 같은 용어를 레포 콘텐츠에서 다르게 쓰면 공식 가이드 문구와 검색·대조가 어려워진다.

| 영어 | 공식 한국어 표기 |
|---|---|
| Task / Skill / Content Domain | 작업 / 기술 / 콘텐츠 도메인 |
| dead-letter queue | 배달 못한 편지 대기열 |
| Lambda layers / destinations / extensions | 계층 / 대상 / 확장 |
| API Gateway stage / stage variables | (API Gateway) 단계 / 스테이징 변수 |
| alias (Lambda) / branch (Amplify) | 별칭 / 분기 |
| bearer token | 전달자 토큰 |
| secret management service | 보안 암호 관리 서비스 |
| sanitize | 정제 (2.3.4) · "마스킹 및 삭제" (2.3.5 masking and sanitization) |
| observability / instrument | 관찰성 / 계측 |
| embedded metric format (EMF) | 임베디드 지표 형식 |
| health checks and readiness probes | 상태 확인 및 준비 상태 프로브 |
| subscription filter policies | 구독 필터 정책 |
| tightly / loosely coupled | 긴밀하게 / 느슨하게 결합된 |
| fault-tolerant and resilient | 내결함성 및 복원력을 갖춘 |
| high-cardinality partition key | 높은 카디널리티 파티션 키 |
| assume an IAM role | IAM 역할 수임 |
| federated access / identity provider | 페더레이션 액세스 / ID 공급자 |
| circuit breaker | 회로 차단기 |
| blue/green · canary · rolling | 블루/그린 · canary(원문 영문) · 롤링 |

---

## 9. 수집 방법·한계

- **도구**: AWS 공식 문서 MCP(`read_documentation`/`search_documentation` — 원문 markdown·chunk), WebFetch, WebSearch. 시험 덤프·문제 유출 사이트는 접근하지 않았다.
- **이번 작업에서 직접 연 공식 페이지**: 가이드 소개·도메인 1~4·개정·in/out-of-scope·기술 및 개념·서비스 언급(EN), 소개·도메인 1~4·개정(KO), 인증 페이지(EN/KO), 2026-09 블로그, 2023 시행 블로그.
- **열람하지 못한 것**: (a) 공식 PDF 본문(docs.aws.amazon.com/pdfs/...는 URL만 확인) (b) 구형 `d1.awsstatic.com` PDF — 압축 스트림이라 WebFetch로 판독 불가, 파일 메타데이터상 생성·수정일 2025-02-12(문서 개정일 아님 — 내용 미확인) (c) DVA-C03 가이드(미공개).
- Task별 노트의 사실은 각 노트의 `## 사실·숫자`·`## 출처 목록`에 URL·조회일과 함께 있고, 확인 못한 항목은 각 노트 `## 확인 필요`와 `99-gaps.md`에 모았다.

## 10. 이 폴더의 파일

| 파일 | 내용 |
|---|---|
| `00-overview.md` | 이 문서 |
| `tasks/1-1.md` … `tasks/4-3.md` | 공식 Task 13개당 1파일: 공식 Skill 원문(EN+KO) · 핵심 개념 · 시험에서 묻는 방식 · 흔한 함정·혼동 짝 · 사실·숫자 · 자가 점검 문항 후보(미검수 초안) · 출처 목록 · 확인 필요 |
| `99-gaps.md` | 상충·불확실·확인 필요 항목 모음, 레포 `DVA-C02.json` 수정 제안 |
