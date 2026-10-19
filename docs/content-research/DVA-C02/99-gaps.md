# 99-gaps — DVA-C02 상충·불확실·확인 필요 · 레포 JSON 수정 제안

> 조회일 **2026-10-17**. 확인되지 않은 것은 노트 본문에 쓰지 않고 여기에 모았다.
> 심각도: 🔴 시한·범위에 영향 / 🟠 사실 확인 필요(출처 상충·미확인) / 🟡 경미·참고.
> 근거 상세는 `00-overview.md`의 해당 절을 가리킨다.

---

## A. 시험·가이드 수준 (공통)

| ID | 심각도 | 항목 | 이유·근거 | 시도한 출처 | 제안·다음 행동 |
|---|---|---|---|---|---|
| G-01 | 🔴 | **DVA-C03 전환** — C02 마지막 응시일 2026-11-30, C03 등록 2026-10-27, C03 GA 2026-12-01. **C03 공식 가이드는 2026-10-27 공개 예정(2026-10-17 현재 없음).** | 블로그 요약만 확보(신규 Task 2.3 AI security, 도메인 3 이름 "Testing and Deployment", 비중 30/26/22/22, DynamoDB 4→1·암호화/민감 데이터 13→7·테스트 11→5·관찰성 8→5·최적화 9→6 통합, 신규 in-scope 서비스). C02→C03 skill 단위 대응은 가이드 공개 전에는 알 수 없음. | 2026-09 공식 블로그, 인증 페이지(EN/KO), `.../developer-associate-03/developer-associate-03.html`(not_found) | 2026-10-27 이후 ① C03 가이드 열람 ② C02 노트와 Skill 대조표 작성 ③ 레포 JSON(`DVA-C03.json` 신설 vs `DVA-C02.json` 개정) 방침 결정 ④ 문항 저작·사람 검수 일정이 2026-11-30 이후 C02 시험 종료와 겹치는지 판단 |
| G-02 | 🟠 | **마지막 응시일 표기 차이**: 영문 "November 30, 2026" vs 한국어 인증 페이지 "2026년 12월 1일" | 공식 설명 없음(원인 미확인 — 단정 금지) | 인증 페이지 EN/KO | 영문 값(11-30)을 기준으로 쓰고 한국어 페이지 갱신 여부 재확인 |
| G-03 | 🟡 | v2.0 게시일이 개정 표에서 공란 | 공식 개정 페이지(EN/KO) 모두 공란 | 개정 페이지 | 필요 시 AWS 인증 지원에 문의. 저작에는 영향 없음 |
| G-04 | 🟠 | **"Emerging topics(새로운 주제)" 절의 추가 시점·버전 미기록** — 개정 표(v2.1, 2024-12-12)에 기록 없음. 현재 EN/KO 가이드 소개 페이지에 있음 | 이 절은 비채점(pretest) 문항 대상이며 AI 보조 개발·AI 서비스 보안·AI 기반 테스트/CI/CD/오류 분석/최적화를 가리킴. 다른 시험 가이드(SAP-C02 등)에도 같은 절이 있다는 검색 결과 확인 | 가이드 소개 페이지, 웹 검색 결과 요약 | 문항 은행의 필수 범위가 아님. DVA-C03 방향 신호로만 참고 |
| G-05 | 🟡 | 공식 PDF(`docs.aws.amazon.com/pdfs/...developer-associate-02.pdf`)·구형 `d1.awsstatic.com` PDF **본문 미열람** | PDF를 판독할 도구가 없었음(WebFetch는 압축 스트림 판독 실패). 구형 PDF 메타데이터 날짜 2025-02-12는 문서 개정일이 아님(내용 미확인) | WebFetch | HTML 가이드(v2.1)를 정본으로 사용. PDF 버전 일치 확인은 사람이 PDF를 열어 하단 개정 표 확인 |
| G-06 | 🟠 | **공식 가이드 내부 불일치**: ① Skill 3.3.3 예시의 "AWS Copilot environments" vs v2.1에서 Copilot을 in-scope에서 제거 ② Skill 문구의 AWS SAM·AWS Private CA가 in-scope 목록에 없음 ③ Skill 4.3.2 EN "Profile…" vs KO "…최적화"(번역 불일치), CodeGuru는 목록에서 제거 ④ Skill 1.2.7 "near real time"(도메인 페이지) vs "real-time"(개정 페이지) | `00-overview.md` §6, §7.3 | 가이드 EN/KO 도메인·개정·in-scope 페이지 | 저작은 **Skill 문구(도메인 페이지) 기준**으로 하되, 해당 서비스의 현재 상태는 Task 노트 `확인 필요`를 참조 |
| G-07 | 🟡 | 비채점 15문항의 도메인 배분과 Task별 출제 비중은 비공개 | 가이드는 도메인 비중(채점 콘텐츠 기준)만 제시. 노트의 "≈16/13/12/9" 환산은 단순 산술 | 가이드 소개 페이지 | 문항 균형은 도메인 비중 기준으로만 맞출 것 |
| G-08 | 🟡 | 실제 시험에는 **multiple response(정답 2개 이상)** 유형이 있으나 앱 문항 스키마는 보기 4개·정답 1개 | 가이드: 선다형·복수 응답형 2유형. 레포: `phase3-content-handoff.md` §3.3 | 가이드, 레포 문서 | 앱 스키마를 바꾸지 않는다면 복수 응답형 학습은 '여러 개를 고르는 시나리오'를 4지선다로 변형해 반영 |

---

## B. 레포 `DVA-C02.json` 수정 제안

대조 결과(상세 `00-overview.md` §7): **Skill 101개·Task 13개 제목·도메인 4개 이름과 비중·시험 메타(720/50/15/130)는 공식 ko_kr 가이드와 불일치 0건.** 아래는 결손·시한 관련 제안이다.

| ID | 구분 | 제안 | 비고 |
|---|---|---|---|
| B-1 | 유지 | Skill 문구·Task 제목·도메인·비중·`overview` 값은 수정하지 않는다 | 공식 값과 일치 |
| B-2 | 선택 | 가이드 버전·게시일(`v2.1`, `2024-12-12`) 메타 추가 검토 | 스키마·로더 영향 확인 필요(코드 변경은 이 작업 범위 밖). 최소한 매핑 문서(`docs/plans/dva-c02-task-mapping.md` 신설 시)에 명시 |
| B-3 | 선택 | Skill 번호(`1.1.1` 형식) 필드 추가 검토 | 문항 `skill` 필드와 노트 표의 번호를 맞추기 위함. 필수는 아님 |
| B-4 | 검토 | `flutter_app/assets/exam_summaries.json` DVA-C02 `outOfScope`에 "IAM 사용자 및 그룹 관리" 추가 검토 | 공식 범위 밖 업무 5개 중 1개가 누락됨(M-4) |
| B-5 | **선행 필수** | DVA-C02 콘텐츠를 `content_index.dart`에 등록하기 **전에** 테스트를 고친다 — `flutter_app/test/content_index_test.dart:10`(`certHasContent('DVA-C02')` isFalse), `:34-37`(`certContentSummary('DVA-C02')` 0), `flutter_app/test/home_sections_test.dart:31`("준비 중" 그룹에서 `DVA-C02` 확인) | '콘텐츠 없음' 예시를 다른 미보유 자격증으로 교체(다른 시험 세션도 같은 영향을 받을 수 있음) |
| B-6 | 시한 | DVA-C03 공개(2026-10-27) 후 `DVA-C03.json` 신설 또는 `DVA-C02.json` 개정 여부 결정. 사이트 메타(`flutter_app/lib/data/site_data.dart:59`, `flutter_app/web/index.html:84,192`)의 코드 표기도 함께 | G-01 연동 |
| B-7 | 참고 | `knowledge: []`는 v2.1 구조(Knowledge 항목 없음)와 맞으므로 유지 | 가이드 개정 페이지 |
| B-8 | 참고 | Skill 4.3.2는 JSON이 ko 원문("애플리케이션 성능 최적화")을 그대로 담고 있음 → 학습문서에서는 EN 원문 "Profile application performance"(프로파일링)를 근거로 다룰 것 | M-3 |

---

## C. Task별 확인 필요 (각 노트 `## 확인 필요`에서 이관)

> 각 노트의 `## 확인 필요` 표에서 **항목 제목만** 옮긴 색인이다. 이유·시도한 출처·제안은 해당 노트의 표(번호 `#N`)에 있다. 항목 제목은 노트 작성 에이전트의 표현 그대로다. (`#` 열이 없는 노트 표는 행 순서대로 번호를 붙였다.)

### C-0. 여러 Task에 반복되는 주제 (요약 — 상세는 각 노트의 표)

| 주제 | 내용 | 관련 항목(Task #번호) |
|---|---|---|
| Lambda 문서 용어·제품군 변화 | 최신 Lambda 문서는 기존 함수를 "Event Function"(이전 명칭 Lambda function)으로 부르고 Managed Instances·MicroVMs·Web Functions·Durable functions를 따로 다룬다. 시험 문구(v2.1)는 "Lambda function" | 1.1 #7 · 1.2 #4·#5 · 3.1 #3 · 3.2 #11 · 3.3 #4 · 3.4 #3 · 4.1 #10 · 4.3 #2 |
| Amazon Q Developer 현황 | IDE 플러그인·유료 구독 2027-04-30 지원 종료, 신규 가입 2026-05-15 차단, 후속 Kiro. 콘솔·문서 사이트 등은 유지. 가이드 v2.1은 Skill 1.1.11·3.3.6과 in-scope 목록에 Q Developer를 유지 | 1.1 #5·#6 · 3.2 #6 · 3.3 #2·#3 · 4.1 #3 |
| AWS Copilot CLI | 노트에 2026-06-12 지원 종료로 기록돼 있으나 Skill 3.3.3 문구 예시에는 남아 있고 in-scope 목록에는 없음 | 3.3 #1·#13 · 3.4 #18 |
| X-Ray SDK/Daemon | 2026-02-25 유지보수 모드, OpenTelemetry 권장. ServiceLens map은 trace map으로 통합 | 3.2 #10 · 4.1 #4 · 4.2 #1·#2 · 4.3 #8·#9 |
| CodeCommit 상태 | 2025-11-25 신규 고객 이용 재개(공식 문서 이력·DevOps 블로그)인데 re:Post 일부 문서는 '신규 고객 불가'로 남아 있음(출처 상충) | 3.1 #1·#2 · 3.4 #1 |
| ECS 배포 | 내장 blue/green(2025-07)·linear/canary(2025-10)·NLB 지원(2026-02)이 가이드 v2.1 이후 출시. CodeDeploy 방식과 구분해야 함 | 3.4 #2 |
| Skill 문구 속 서비스 vs in-scope 목록 | SAM·Private CA·Copilot·CodeCommit·CodeGuru 등이 문구에는 나오나 목록에 없거나 v2.1에서 제거됨 | 1.1 #19 · 1.2 #10 · 1.3 #22 · 2.1 #12 · 2.2 #7 · 3.1 #13 · 3.3 #11 · 3.4 #17 · 4.1 #13 · 4.2 #15 |
| 수치·서술의 출처 간 상충 | KMS 온디맨드 회전 한도 10 vs 25(2.2 #1), Logs Insights 동시 쿼리 30 vs 100(4.1 #1·4.3 #10), API Gateway 스테이지 설정 변경 후 재배포 서술(3.2 #2·3.3 #5·3.4 #7), ECR 태그 불변성 서술(3.3 #6·3.4 #9), SQS 이벤트 소스 매핑 프로비저닝 모드 수치(1.2 #1), SnapStart 런타임·요금 서술(4.3 #4), Lambda 오소라이저 TTL 0 허용(2.1 #3), X-Ray 어노테이션 키 규칙(4.2 #3) | 좌동 |
| 인용 신뢰도 주의 | 노트 작성 중 1.2·1.3 에이전트가 What's New류 **검색 chunk가 실제 페이지 문구와 달라** 원문으로 교체한 사례를 보고(1.2: 비동기 1 MB 행, 1.3: 2024-11 가격 인하 행). 다른 노트의 What's New·블로그 인용에도 같은 위험이 있어 출제 전 재확인 권장 | — |
| 분량·분할 | 노트 13개 합계 6,154줄(파일당 321~617줄). CLF 학습문서는 파일당 133~249줄. 노트는 재료라 길지만, 저작 시 Task 1.1(13 Skill)·3.4(11 Skill)처럼 표면이 넓은 Task는 문서 1개로 담기 벅찰 수 있어 분할 여부를 저작 단계에서 판단 | 1.1 · 3.4 · 1.2 · 2.1 |

### Task 1.1 — AWS에서 호스팅되는 애플리케이션 코드 개발  (`tasks/1-1.md` §확인 필요 · 20건)

- #1 SDK 재시도 기본값(모드·최대 시도·백오프)
- #2 AWS CLI v2의 새 재시도 동작
- #3 Kinesis 레코드 최대 크기·샤드 쓰기 한도
- #4 EventBridge 버스 유형 변경
- #5 Amazon Q Developer 제품 상태
- #6 Q Developer 기능 명칭
- #7 Lambda 용어
- #8 SQS 최대 메시지 크기
- #9 SNS 기본 메시지 크기·상향 시 제약
- #10 EventBridge 이벤트 크기
- #11 EventBridge Scheduler 수치
- #12 Builders' Library 원문
- #13 API Gateway REST 통합 타임아웃 29초
- #14 AppSync 개요
- #15 Powertools 멱등성 기본 기간
- #16 SQS `ReceiveMessage`의 `MaxNumberOfMessages` 범위·기본값
- #17 Firehose 명칭
- #18 가이드 이후 신규 기능
- #19 SAM 및 Skill 문구 속 서비스 상태
- #20 adaptive 모드·서킷 브레이커 평가 차이

### Task 1.2 — AWS Lambda용 개발 코드  (`tasks/1-2.md` §확인 필요 · 16건)

- #1 SQS ESM 프로비저닝 모드 수치 상충
- #2 스트림 ESM 실패 대상 허용 종류
- #3 스트림 `MaximumRetryAttempts` 최솟값
- #4 용어 "Event Functions"
- #5 신규 컴퓨팅 형태·기능의 시험 범위
- #6 비동기 페이로드 한도
- #7 런타임 목록·종료 일정
- #8 변동 가능한 제약(SnapStart·Compute Optimizer)
- #9 Lambda 요금 단가
- #10 공식 in-scope 목록 밖 도구
- #11 SQS `BatchSize` 10,000 조건
- #12 API Gateway↔Lambda 통합 한도
- #13 다른 Task로 넘긴 상세
- #14 Init 한도 서술
- #15 콘솔·UI·로그 형식
- #16 Hyperplane ENI 준비 시간 표기

### Task 1.3 — 애플리케이션 개발 시 데이터 스토어 사용  (`tasks/1-3.md` §확인 필요 · 22건)

- #1 스켈레톤의 🆕·✏️ 표기
- #2 GSI 멀티 속성 복합 키(2025-11)와 시험 문구
- #3 트랜잭션 한도(고유 항목 100개·4 MB)
- #4 용량 모드 전환 횟수
- #5 TTL 삭제 시점
- #6 S3 최대 객체 크기
- #7 S3 Lifecycle: 30일 미만 객체의 Standard-IA·One Zone-IA 전환
- #8 `CreateTable` BillingMode 생략 시 API 기본값
- #9 Boto3의 float 처리
- #10 DAX 쿼리 캐시 TTL 기본값
- #11 DAX 종료·중단 공지
- #12 ElastiCache 엔진 표기
- #13 벡터 검색(DynamoDB 2026-08 GA)·Valkey 전문 검색의 시험 범위
- #14 단일 테이블 vs 다중 테이블
- #15 MRSC 지원 Region 수·구성
- #16 Standard-IA 선택 기준
- #17 PITR 복원 시 자동 복사되지 않는 설정
- #18 온디맨드 현행 단가
- #19 Athena 현행 단가
- #20 OpenSearch 기본 샤드 수
- #21 이번 노트의 조사 제외 범위
- #22 Skill 문구에 있으나 in-scope 목록에 없는 서비스(SAM·Private CA·Copilot·CodeCommit·CodeGuru)

### Task 2.1 — 애플리케이션 및 AWS 서비스에 대한 인증 또는 권한 부여 구현  (`tasks/2-1.md` §확인 필요 · 12건)

- #1 Amazon Verified Permissions의 시험 범위 여부
- #2 Skill 2.1.8의 서비스 커버리지
- #3 Lambda 오소라이저 TTL 0 허용 여부(출처 간 상충)
- #4 REST Cognito 오소라이저의 스코프 미지정 동작
- #5 Cognito 요금 단가
- #6 명칭·조건 변경(Hosted UI → managed login·classic hosted UI, ASF → Essentials/Plus, 액세스 토큰 커스터마이징 요건)
- #7 최근 추가 기능의 시험 범위(`aws login`, Cognito `GetClientToken`·`ALLOW_CLIENT_TOKEN_AUTH`, 사전 토큰 생성 V3_0)
- #8 IAM 정책 유형의 개수·구성
- #9 서비스가 수임하는 세션의 수명(Lambda 실행 역할·ECS 작업 역할 자격 증명)
- #10 액세스 토큰의 `aud` 클레임
- #11 IAM Identity Center 세부
- #12 Skill 문구 밖 서비스(AWS SAM·Private CA·Copilot·CodeCommit·CodeGuru) 현황

### Task 2.2 — AWS 서비스를 사용하여 암호화 구현  (`tasks/2-2.md` §확인 필요 · 12건)

- #1 KMS 온디맨드 회전 한도(10 vs 25)
- #2 ACM 공개 인증서 유효기간
- #3 S3 SSE-C 기본 차단
- #4 EC2 키 페어 RSA 길이 서술
- #5 KMS 요청 쿼터 수치
- #6 SQS 신규 큐 기본 암호화
- #7 AWS Private CA 범위
- #8 ACM 신규 기능과 시험 범위
- #9 AWS CLI v1 상태
- #10 "AWS 통합 서비스는 대칭 KMS 키만 지원" 일반화
- #11 DynamoDB 클라이언트측 라이브러리 명칭
- #12 서비스별 교차 계정 KMS 권한 목록

### Task 2.3 — 애플리케이션 코드에서 민감한 데이터 관리  (`tasks/2-3.md` §확인 필요 · 13건)

- #1 Parameter Store 세부(자동 회전 여부·버전/라벨·고급 티어 요금·처리량·다중 Region)
- #2 Secrets Manager 시크릿 개수 상한·API 요청 쿼터
- #3 Secrets Manager 무료 사용
- #4 CloudWatch Logs managed data identifier 개수
- #5 Powertools 데이터 마스킹 유틸리티
- #6 Lambda tenant isolation mode·SQS fair queues 시험 범위
- #7 Amazon Macie 범위
- #8 Lambda 암호화 도우미의 암호화 컨텍스트
- #9 RDS 관리형 마스터 비밀번호의 기본 회전 주기·요금
- #10 ECS Fargate 플랫폼 버전 요건
- #11 CloudFormation `NoEcho` 파라미터
- #12 PII·PHI 정의의 공식 출처
- #13 SaaS 격리 문서의 최신성

### Task 3.1 — AWS에 배포할 애플리케이션 아티팩트 준비  (`tasks/3-1.md` §확인 필요 · 13건)

- #1 CodeCommit 서비스 상태(가이드 문구·옛 자료와 불일치)
- #2 CodeCommit 로드맵(Git LFS 2026년 1분기, eu-south-2·ca-west-1 2026년 3분기부터)과 리전 수
- #3 Lambda 문서의 용어·제품군 변화
- #4 ECS Fargate 32 vCPU 행
- #5 Elastic Beanstalk "Standard/Cluster" 구분
- #6 CodeBuild 소스 공급자 목록 상충
- #7 CodeConnections 미지원 Region 목록
- #8 AppConfig 신기능·명칭
- #9 AppConfig·Parameter Store 요금 수치
- #10 Lambda 환경 변수 암호화 기본 키
- #11 Lambda Power Tuning의 성격
- #12 CloudFormation `.md` URL
- #13 Skill 3.1 문구에 없는 서비스(AWS Private CA·AWS Copilot·CodeGuru)

### Task 3.2 — 개발 환경에서 애플리케이션 테스트  (`tasks/3-2.md` §확인 필요 · 13건)

- #1 [상충·옛 자료 불일치] Step Functions Local
- #2 [상충] 스테이지 설정 변경 후 재배포 필요 여부
- #3 [미확인] API Gateway 콘솔 Test 화면
- #4 [신규·범위 불명] CloudFormation Express 모드·`sam deploy --express`
- #5 [최신성] AWS IATK
- #6 [최신성] Amazon Q Developer 테스트 생성
- #7 [3자·미확인] LocalStack·Moto
- #8 [미확인] SQS 관련 수치
- #9 [미확인] EventBridge 요금·한도
- #10 [범위 밖 미조사] X-Ray 계측 방식 변화
- #11 [최신성] Lambda 문서의 용어 변화
- #12 [미조사] Skill 3.2.2(✏️) 변경 전 문구
- #13 [표기] `.md` URL

### Task 3.3 — 배포 테스트 자동화  (`tasks/3-3.md` §확인 필요 · 16건)

- #1 AWS Copilot CLI(Skill 3.3.3 문구) 지원 종료
- #2 Amazon Q Developer 현황(Skill 3.3.6)
- #3 Q Developer 단위 테스트 생성의 현재 지원 언어·프레임워크
- #4 Lambda 용어 변경
- #5 API Gateway 문서 간 불일치: 스테이지 설정 변경 후 재배포
- #6 ECR 태그 불변성 서술 상충
- #7 일반(비가중) Lambda 별칭이 `$LATEST`를 가리킬 수 있는지
- #8 HTTP API 자동 배포 기본값
- #9 API Gateway 콘솔 Test가 '배포 없이' 가능한지
- #10 SAM 리소스 유형 14종 목록
- #11 AWS SAM의 In-Scope 목록 부재
- #12 Amplify 범위·한도
- #13 Copilot 환경 상세
- #14 SAM 암묵적/명시적 API의 스테이지 이름 동작
- #15 문서 예제의 런타임 표기
- #16 SAM CLI 서비스·옵션 목록의 버전 의존성

### Task 3.4 — AWS 지속적 통합 및 지속적 전달(CI/CD) 서비스로 코드 배포  (`tasks/3-4.md` §확인 필요 · 20건)

- #1 CodeCommit 현재 상태(출처 간 상충)
- #2 ECS 배포: 시험 문구 vs 현황
- #3 'Lambda function' 명칭
- #4 Elastic Beanstalk "Standard / Cluster"
- #5 API Gateway 라우팅 모드 '기본/권장' 표기
- #6 REST API 스테이징 변수 이름 규칙
- #7 스테이지 설정 변경 뒤 재배포 필요 여부
- #8 카나리 릴리스의 HTTP API 지원
- #9 ECR 태그 불변성 설명의 내부 불일치
- #10 CodePipeline Lambda 배포 작업의 세부
- #11 CodeBuild 빌드 제한시간
- #12 CodePipeline V1/V2 요금 구조
- #13 CodeDeploy ECS 원본 작업 세트 종료 대기 시간·승인 대기 한도
- #14 Skill 3.4.9 '레이블'의 구체적 의미
- #15 Skill 3.4.7 '오케스트레이션된 워크플로'의 서비스
- #16 Skill 3.4.4 '환경 관리' 경계
- #17 AWS SAM 서비스 상태
- #18 AWS Copilot CLI(인접)
- #19 Lambda 자체 관리 S3 코드 저장(`REFERENCE`)
- #20 API Gateway 라우팅 규칙의 Region 가용성·쿼터

### Task 4.1 — 근본 원인 분석 지원  (`tasks/4-1.md` §확인 필요 · 13건)

- #1 Logs Insights 동시 쿼리 한도(100 vs 30)
- #2 Infrequent Access 로그 클래스
- #3 Amazon Q Developer 서비스 현황
- #4 X-Ray SDK·데몬 maintenance mode
- #5 대시보드 Logs Insights 위젯 범위
- #6 Application Signals의 Lambda 지원
- #7 CloudFormation 스택 상태 표 URL
- #8 CodeBuild 로그 저장 설정
- #9 API Gateway HTTP API·WebSocket API
- #10 Lambda 문서 개편
- #11 Elastic Beanstalk 신규 환경 유형
- #12 Lambda remote debugging 범위
- #13 공식 가이드 Skill 문구 ↔ SAM 등

### Task 4.2 — 코드 계측을 통해 관찰성 향상  (`tasks/4-2.md` §확인 필요 · 15건)

- #1 X-Ray SDK·데몬 maintenance vs 공식 가이드 v2.1 문구
- #2 ADOT 상태·명칭
- #3 어노테이션 키 규칙 상충
- #4 메타데이터 한도
- #5 Powertools Tracer의 X-Ray SDK 의존·OTel 지원
- #6 `PutMetricData` 기본 쿼터 500 TPS
- #7 Powertools 문서 버전
- #8 로그 경보(log alarm)·PromQL 경보
- #9 Service Quotas 경보 지원 범위
- #10 AWS Chatbot 명칭·연동 대상
- #11 빌드·스택 완료 알림
- #12 EKS 프로브 기본값
- #13 ECS 유예 기간 값 범위
- #14 Beanstalk 향상된 상태 판정 수치
- #15 공식 가이드 Skill 문구 ↔ 서비스

### Task 4.3 — AWS 서비스 및 기능을 사용하여 애플리케이션 최적화  (`tasks/4-3.md` §확인 필요 · 20건)

- #1 4.3.2 번역 불일치
- #2 Lambda 문서 용어 변경
- #3 S1 내부 불일치(스케일링 속도)
- #4 SnapStart 런타임·요금 서술 불일치
- #5 Compute Optimizer의 아키텍처 제한
- #6 CodeGuru Profiler 현황
- #7 Amazon DevOps Guru sunset
- #8 X-Ray SDK/Daemon 유지보수 모드
- #9 ServiceLens 용어 통합
- #10 Logs Insights 동시 쿼리 한도
- #11 SNS 필터 불일치 메시지와 DLQ
- #12 SNS 와일드카드 단락 표기
- #13 SNS FIFO 토픽 필터
- #14 Power Tuning 상세
- #15 API Gateway 캐시 용량 값
- #16 ElastiCache 문서 구조
- #17 한도·기본값의 가변성
- #18 SQS 이벤트 소스 BatchSize 근거
- #19 Lambda Insights 세부
- #20 신규 Skill(4.3.6~4.3.9)의 출제 범위


---

## D. 건수 요약

| Task | 제목 | 확인 필요 건수 | 출처 수 | 사실·숫자 행 | 문항 후보 | 노트 |
|---|---|---|---|---|---|---|
| 1.1 | AWS에서 호스팅되는 애플리케이션 코드 개발 | 20 | 95 | 53 | 5 | `tasks/1-1.md` |
| 1.2 | AWS Lambda용 개발 코드 | 16 | 70 | 65 | 5 | `tasks/1-2.md` |
| 1.3 | 애플리케이션 개발 시 데이터 스토어 사용 | 22 | 75 | 51 | 5 | `tasks/1-3.md` |
| 2.1 | 애플리케이션 및 AWS 서비스에 대한 인증 또는 권한 부여 구현 | 12 | 77 | 42 | 5 | `tasks/2-1.md` |
| 2.2 | AWS 서비스를 사용하여 암호화 구현 | 12 | 69 | 35 | 5 | `tasks/2-2.md` |
| 2.3 | 애플리케이션 코드에서 민감한 데이터 관리 | 13 | 60 | 36 | 5 | `tasks/2-3.md` |
| 3.1 | AWS에 배포할 애플리케이션 아티팩트 준비 | 13 | 61 | 48 | 5 | `tasks/3-1.md` |
| 3.2 | 개발 환경에서 애플리케이션 테스트 | 13 | 59 | 54 | 5 | `tasks/3-2.md` |
| 3.3 | 배포 테스트 자동화 | 16 | 75 | 51 | 5 | `tasks/3-3.md` |
| 3.4 | AWS 지속적 통합 및 지속적 전달(CI/CD) 서비스로 코드 배포 | 20 | 75 | 51 | 5 | `tasks/3-4.md` |
| 4.1 | 근본 원인 분석 지원 | 13 | 74 | 59 | 5 | `tasks/4-1.md` |
| 4.2 | 코드 계측을 통해 관찰성 향상 | 15 | 73 | 57 | 5 | `tasks/4-2.md` |
| 4.3 | AWS 서비스 및 기능을 사용하여 애플리케이션 최적화 | 20 | 88 | 59 | 5 | `tasks/4-3.md` |
| **합계** | | **205** | **951** | **661** | **65** | |

---

## E. 최종 검증 결과 (2026-10-19 — 임시 lint 스크립트 실행 뒤 삭제)

### E.1 구조·형식 lint (노트 13개 + 최상위 문서 3개)

| 검사 | 결과 |
|---|---|
| 레포 `DVA-C02.json`의 Skill 101개 ↔ 노트 상단 한국어 Skill 표 | 불일치 0 |
| 필수 섹션 7개 존재·순서, `_(작성 대기)_` 잔존 | 13/13 정상, 잔존 0 |
| 공식 Skill 번호 101개가 `## 핵심 개념`에서 언급됨 | 101/101 |
| 본문 `[S#]` ↔ `## 출처 목록` 정합 | 미정의 참조 0, 목록에만 있고 본문에 없는 출처 1(1-2) |
| `## 사실·숫자` 표 행의 URL·조회일 누락 | 0 (661행) |
| 표 열 수 불일치(노트 13 + 최상위 3) | 0 |
| 인용 15단어 초과(인용 조각 기준) | 실제 위반 1행(경미): `tasks/4-2.md` 사실 #17 — 16단어(1단어 초과). 나머지 2행(`1-1.md` #34, `4-2.md` #45)은 라벨·괄호 때문에 생긴 계수 오탐으로, 조각별로는 15단어 이내 |
| 고립된 `[S#]` 줄(미관) | 2건: `tasks/3-1.md` 263행 `[S32]`, `tasks/4-2.md` 135행 `[S34]` |
| 문항 후보 | 13 Task × 5 = 65, 각 3개 이상 |

### E.2 URL 생존 점검 (HEAD/GET, 15개 파일에서 수집)

고유 URL 831개 중 828개 점검 → **823개 2xx**(리다이렉트 3), 5개 비정상. 5개는 모두 인용 출처가 아니다:
`.../developer-associate-03/developer-associate-03.html`(404 — C03 가이드 미공개의 증거로 의도적 기재), `http://127.0.0.1:3001`(SAM local 예시), `https://cognito-idp…`(코드 예시의 잘린 템플릿), `https://{dev|main}.appid.amplifyapp.com`(Amplify 브랜치 URL 예시). 템플릿 3개(`${stageVariables.url}`·`{api_id}…`·`{restapi-id}…`)는 점검 제외. 리다이렉트 중 Builders' Library "Timeouts, retries, and backoff with jitter"는 `builder.aws.com`으로 이전됐다.

### E.3 인용 원문 대조 (`## 사실·숫자` 표 전수 661행)

각 행의 인용 조각이 해당 행에 적힌 URL의 **현재 페이지 본문**에 그대로 있는지 대조했다(공백·따옴표·대시·마크다운 기호·표 구분자 차이는 무시). 결과: **658행 일치 / 3행 불일치**. 불일치 3행은 모두 값(사실) 자체는 맞고 인용 표기만 어긋난다:

| 위치 | 문제 | 페이지에서 확인한 원문(교체 권장 인용, 15단어 이내) |
|---|---|---|
| `tasks/2-3.md` 사실 #34 (SQS fair queues) | 따옴표 인용이 **의역**(What's New 검색 chunk 요약을 원문처럼 인용) | "include a message group ID when sending messages to your Amazon SQS standard queues" — https://aws.amazon.com/about-aws/whats-new/2025/07/amazon-sqs-introduces-fair/ |
| `tasks/3-4.md` 사실 #38 (ECS 내장 canary) | 따옴표 인용이 **의역**(같은 유형) | "route a small percentage of production traffic to your new service revision" — https://aws.amazon.com/about-aws/whats-new/2025/10/amazon-ecs-built-in-linear-canary-deployments/ |
| `tasks/4-2.md` 사실 #50 (ECS 상태 확인 유예) | 최대값 인용 "up to 2,147,483,647 seconds"가 **적힌 CDK 페이지에 없음**(그 페이지엔 기본값 0 문장만 있음). 값은 ECS 콘솔 도움말 페이지에서 확인됨 | "a health check grace period of up to 2,147,483,647 seconds" — https://docs.aws.amazon.com/help-panel/AmazonECS/latest/console/hp-deploy-loadbalancing-healthcheckgraceperiod.html |

위 3행은 컨트롤러 지시("기존 파일 보존")에 따라 **수정하지 않았다.** 교체가 필요하면 위 문구로 한 셀씩 바꾸면 된다.

### E.4 이 검증의 한계

- E.3은 **인용 문구가 페이지에 존재하는지**만 확인한다. `값/규칙` 열의 요약, 본문 서술의 `[S#]` 주장, 문항 후보의 정답·해설이 인용과 의미상 일치하는지는 노트 작성 에이전트의 자체 점검 외에 독립 검증하지 않았다(문항 후보는 모두 미검수 초안).
- **중단된 에이전트 4개**(Task 1.1 · 2.2+2.3 · 3.1+3.2 · 4.1+4.2)는 2026-10-17 17:50경 계정 사용 한도(HTTP 429)로 **자체 점검 단계에서 끊겼다.** 파일은 완성 상태이고 위 lint도 정상이지만, 중단 직전에 하려던 보정 일부(예: 3-1의 표현 4곳 완화, 고립된 `[S#]` 줄 정리, 4-2 출처 보강)는 반영되지 않았을 수 있다. 트랜스크립트가 커서(에이전트당 약 60만 토큰) 재개하지 않았다.
- 노트 작성 중 에이전트들이 보고한 바(1.2·1.3): What's New류 **검색 chunk는 실제 페이지 문구와 다를 수 있다** — 위 불일치 2행(2-3 #34, 3-4 #38)이 같은 유형이다. What's New·블로그 출처의 인용은 출제 전 재확인을 권한다.

