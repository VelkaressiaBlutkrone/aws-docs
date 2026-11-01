# 96 — DVA-C03 전환 대비: C02 Task 노트 재사용 분류

> 🏁 **역할을 마쳤다 (2026-11-01).** 공식 C03 가이드가 공개돼 아래 §6 체크리스트 5건을 전부 닫았다. **정본은 [`../DVA-C03/00-overview.md`](../DVA-C03/00-overview.md)(가이드 실측)와 [`../DVA-C03/97-c02-c03-remap.md`](../DVA-C03/97-c02-c03-remap.md)(재매핑)다.**
>
> ⚠️ **이 문서의 추정 중 실측과 어긋난 것이 있다 — 그대로 쓰지 말 것:**
> - **§2·§5의 A/B 분류는 폐기됐다.** "A(그대로 재사용)"로 분류한 6개 Task(1.1·1.2·2.1·3.1·3.4·4.1)가 **전부 B**다. AI Skill이 5개 Task에 새로 박혔고 공식 재배치가 5건 있다. 특히 **Task 1.2(Lambda)는 Skill 4개로 줄고 성능 튜닝이 4.3으로 이동**했으며, **Task 3.4는 아예 없어졌다**(C03 도메인 3은 Task 3개).
> - **§1의 통합 배분이 두 칸 뒤집혀 있었다** — 암호화/민감데이터는 C02 2.2가 **6**·2.3이 **7**이고, 테스트는 3.2가 **6**·3.3이 **5**다. 합계만 맞았다.
> - **신규 in-scope는 「Amazon Q」가 아니라 「Amazon Quick」이다**(`Amazon Q Developer`라는 이름은 목록에 없고, `Amazon Quick Sight`는 out-of-scope).
> - **캐싱은 한쪽으로 합쳐지지 않았다** — C03 1.3.3과 4.3.4 양쪽에 있다.
>
> 아래 본문은 **작성 시점의 추정 기록**으로 남긴다.

> **⚠️ 미확정 문서.** DVA-C03 공식 시험 가이드는 **2026-10-27 공개 예정이며, 2026-10-19 현재 문서 사이트에 없다**(`.../aws-certification/latest/developer-associate-03/developer-associate-03.html` → `not_found`, 2026-10-17·2026-10-19 두 번 확인). 이 문서의 C03 내용은 전부 AWS **공식 블로그의 '예고' 문장**에서 왔고 가이드 공개 전까지 확정 사실이 아니다. 특히 §1의 "C02 대응(추정)"은 블로그가 적은 skill 개수가 **C02 가이드의 skill 개수와 일치**한다는 데서 추론한 것이다(추정).
>
> - 근거 블로그: https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ — 조회 2026-10-17, 재확인 2026-10-19(본문 변화 없음)
> - 분류 근거: 블로그 예고 + 각 노트(`tasks/*.md`)의 소주제 제목·키워드 검색 결과(노트 전문을 다시 읽은 것은 아님)
> - C03 가이드가 공개되면 컨트롤러가 이 표로 기계적으로 재매핑한다. 이 문서는 공개를 기다리지 않는다.

**재사용 분류 정의**

| 분류 | 뜻 |
|---|---|
| **A** | 서비스·개념 중심이라 Task/Skill 번호가 바뀌어도 **그대로 재사용** |
| **B** | **일부 수정 필요** — 블로그 예고상 통합·이동이 걸린 Task(재배열·재편 필요) |
| **C** | **신설 영역** — 대응 노트 없음(또는 인접 노트만 있음) |

---

## 1. 블로그가 예고한 C03 변경 (미확정) ↔ C02 대응(추정)

출처: 위 블로그의 "Coming soon: AWS Certified Developer – Associate (DVA-C03)" 절. 인용은 15단어 이내.

| 예고 항목 | 블로그 문장(인용) | C02 대응(추정 — skill 개수 일치 근거) |
|---|---|---|
| DynamoDB 통합 | "DynamoDB: 4 separate skills consolidated into 1 comprehensive skill" | C02 Skill 1.3.1(파티션 키)·1.3.2(일관성)·1.3.3(Query/Scan)·1.3.4(키·인덱싱) = DynamoDB 관련 4개 |
| 암호화·민감 데이터 통합 | "13 skills across 2 tasks consolidated into 7 skills in 1 task" | C02 Task 2.2(7) + 2.3(6) = 13 |
| 테스트 통합 | "Testing: 11 skills across 2 tasks consolidated into 5 skills in 1 task" | C02 Task 3.2(5) + 3.3(6) = 11 |
| 관찰성 통합 | "Observability: 8 skills consolidated into 5 skills" | C02 Task 4.2(8) |
| 최적화 통합 | "Optimization: 9 skills consolidated into 6 skills" | C02 Task 4.3(9) |
| 신규 Task | "New Task 2.3 — AI security (5 skills)" | 대응 없음(신설). **번호 충돌**: C02 2.3(민감 데이터)은 위 통합으로 C03 2.2에 흡수되는 것으로 추정되고, C03 2.3은 다른 Task |
| AI 보조 개발 확산 | "AI-assisted development across all domains" | C02 Skill 1.1.11·3.3.6(Q Developer)과 부분 접점 |
| 컨테이너 관리 | "Building and managing container images with Amazon ECR" (+ECS·EKS·Fargate 배포) | C02 노트에 흩어진 인접 내용(§3 참조) |
| 신규 in-scope 서비스 | "Amazon Bedrock, Amazon Bedrock AgentCore, Amazon Q, Kiro, Amazon Data Firehose, AWS PrivateLink" | §3 참조 |
| 도메인 구성 | "Testing and Deployment (22%)" (1: 30% · 2: 26% · 3: 22% · 4: 22%) | C02는 32/26/24/18, 도메인 3 이름 "Deployment" |

---

## 2. C02 Task 13개 ↔ 재사용 분류

형식: `C02 Task | 다룬 주제 | 분류 | 한 줄 근거`. "다룬 주제"는 각 노트의 `###` 소주제를 요약한 것이다.

| C02 Task | 다룬 주제 | 분류 | 한 줄 근거 |
|---|---|---|---|
| **1.1** (`tasks/1-1.md`) | 아키텍처 패턴(모놀리스·마이크로서비스·이벤트 기반, 코레오그래피 vs 오케스트레이션, 팬아웃), 스테이트풀/리스·결합도·동기/비동기, 내결함성·서드파티 복원력(재시도·백오프·서킷 브레이커), API Gateway 요청/응답 변환, SAM 단위 테스트, SQS·SNS, SDK, 스트리밍(Kinesis·Firehose), Q Developer, EventBridge | **A** | 서비스·개념 중심이라 번호와 무관하게 재사용. 단 §Q Developer(Skill 1.1.11)는 제품 현황 변화와 C03 'AI 보조 개발' 예고로 손볼 가능성(§4) |
| **1.2** (`1-2.md`) | Lambda 전반: VPC 연결, 구성(메모리·타임아웃·환경 변수·런타임·계층·확장·동시성), 트리거·Destinations vs DLQ, 호출 유형별 오류 처리, 이벤트 소스 매핑(부분 배치 응답), 멱등성, 테스트 도구, 성능 튜닝, 준실시간 처리 | **A** | 블로그가 Lambda skill의 통합·이동을 예고하지 않음. 서비스 재료 그대로 재사용 |
| **1.3** (`1-3.md`) | DynamoDB(파티션 키·일관성·Query/Scan·키/LSI/GSI), 직렬화, 데이터 스토어 사용·관리, 수명 주기(TTL·S3 Lifecycle), 캐싱(ElastiCache·DAX), 특수 스토어(OpenSearch 등) | **B** | DynamoDB 4개 skill → 1개 통합 예고 — 1.3.1~1.3.4 소주제를 한 skill로 재배열. 캐싱(1.3.8)은 4.3.6과 겹쳐 최적화 통합 시 이동 가능 |
| **2.1** (`2-1.md`) | Cognito 사용자 풀/자격 증명 풀, IdP 페더레이션, JWT·OAuth 2.0, API Gateway 인증 방식 비교, 자격 증명 공급자 체인·SigV4·AssumeRole, IAM 정책 유형·평가, 앱 수준 세분화 권한, 서비스 간 인증 | **A** | 통합 예고 대상이 아님. C03 신설 'AI 서비스 접근 관리'는 인접 영역(§3) |
| **2.2** (`2-2.md`) | 저장 중/전송 중 암호화, TLS 종단, ACM·Private CA, 클라이언트측 vs 서버측, KMS 키 유형·키 정책·봉투 암호화, 개발용 인증서·SSH 키, 교차 계정 암호화, 키 회전 | **B** | 암호화·민감 데이터 13 skill(2 task) → 7 skill(1 task) 통합 예고. 2.3과 합쳐 7개 skill로 재편될 가능성(추정) |
| **2.3** (`2-3.md`) | 데이터 분류(PII·PHI), 환경 변수 암호화, Secrets Manager vs Parameter Store·회전·버전 스테이지, 런타임 조회·캐싱·주입, 정제·마스킹, 멀티테넌트 데이터 접근 | **B** | 위 통합의 다른 한쪽. ⚠️ **번호 충돌**: C03 Task 2.3은 'AI security'(신설)라 C02 2.3과 다른 Task — 번호가 아니라 주제로 매핑할 것 |
| **3.1** (`3-1.md`) | Lambda 패키지(.zip·컨테이너 이미지·계층), 의존성 번들링, 컨테이너 이미지·ECR, 디렉터리·SAM 프로젝트 구조, 코드·아티팩트 저장소(CodeCommit 현황), 리소스 요구(메모리·CPU), AppConfig·환경별 구성 | **A** | 통합 예고 대상이 아님. 컨테이너 이미지 절은 C03 '컨테이너 관리'와 접점(§3) |
| **3.2** (`3-2.md`) | 테스트 유형·기법, 배포된 코드 테스트 도구, 통합 테스트·모의 API, 개발 엔드포인트(스테이지·변수·카나리), 스택 업데이트 배포, 이벤트 기반 앱 테스트 | **B** | 테스트 11 skill(2 task) → 5 skill(1 task) 통합 예고. 3.3과 합쳐 재편 가능성(추정). 도메인 3 이름도 'Testing and Deployment'로 바뀜 |
| **3.3** (`3-3.md`) | 테스트 이벤트(Lambda·서비스별 페이로드), API 배포(Deployment+Stage·변수·HTTP API·카나리), Lambda 버전·별칭·이미지 태그·Amplify 브랜치·Copilot 환경, IaC(SAM·CloudFormation·CDK), 서비스별 환경 구분, Q Developer 테스트 생성 | **B** | 위 통합의 다른 한쪽. Copilot·Q Developer 절은 서비스 현황 변화로 추가 손질 필요(§4) |
| **3.4** (`3-4.md`) | Lambda 패키징, API Gateway 스테이지·사용자 지정 도메인, IaC 업데이트, 환경 관리, 배포 전략(CodeDeploy·ECS·Beanstalk), 커밋→파이프라인, 오케스트레이션·승인, 롤백, 레이블·분기, 스테이징 변수 | **A** | 통합 예고 대상이 아님(서비스·개념 중심). 'CI/CD 배포 승인 자동화(AI)'·'ECS/EKS/Fargate 배포'는 §3 신설 영역으로 따로 처리 |
| **4.1** (`4-1.md`) | 분석 흐름(지표→트레이스→로그), 코드 디버깅, 지표·로그·추적 해석, Logs Insights 쿼리, EMF 사용자 지정 지표, 대시보드·인사이트, 배포 실패 로그, 서비스 통합 디버깅 | **A** | 통합 예고 대상이 아님. 'AI 오류 분석·문제 해결 제안'은 §3 신설 영역 |
| **4.2** (`4-2.md`) | 로깅·모니터링·관찰성 구분, 로깅 전략·구조화 로깅, 사용자 지정 지표 코드, X-Ray 어노테이션·추적, 알림(쿼터·배포 완료), 헬스 체크·준비 프로브 | **B** | 관찰성 8 skill → 5 skill 통합 예고(4.2의 skill 8개와 일치, 추정). X-Ray SDK 유지보수 모드 반영 필요(§4) |
| **4.3** (`4-3.md`) | 동시성, 프로파일링 도구, 최소 메모리·컴퓨트, SNS 필터 정책, CloudFront 헤더 캐싱, 앱 수준 캐싱, 리소스 사용 최적화, 성능 문제 분석, 로그 기반 병목 | **B** | 최적화 9 skill → 6 skill 통합 예고(4.3의 skill 9개와 일치, 추정). 4.3.2 한·영 번역 불일치·CodeGuru Profiler 현황 미확정(§4) |

---

## 3. C03 예고 신설·확장 영역 ↔ 현재 노트 대응

| 예고 영역(미확정) | 현재 노트 대응 | 분류 |
|---|---|---|
| **신규 Task 2.3 AI security**(5 skills): AI 서비스 접근 관리, 데이터 프라이버시 제어(VPC 엔드포인트·입출력 모델 학습 미사용), 콘텐츠 필터링·프롬프트 인젝션 방어, AI 에이전트 상호작용 보안(도구 사용 권한·세션 격리·사람 승인), 모니터링 로그의 민감 콘텐츠 보호 | **대응 노트 없음.** 노트 전체에서 '프롬프트 인젝션'·Bedrock Guardrails·AgentCore 언급 0건(검색 확인; 2-3의 '가드레일'은 IAM 정책 가드레일 의미). 인접: `2-3.md` §민감 데이터 정제(로그), `2-1.md` §IAM·접근 관리 | **C** |
| **AI 보조 개발(전 도메인)**: 코드 생성·자동 리뷰(D1), 테스트 자동화·회귀·CI/CD 배포 승인 자동화(D3), 오류 분석·최적화 권고(D4) | **부분 인접.** `1-1.md` §Q Developer(1.1.11), `3-3.md` §Q Developer 테스트 생성(3.3.6), `4-1.md`·`3-2.md`의 현황 메모. Kiro 후속·AI 기반 배포 승인·오류 분석·최적화 권고는 대응 없음 | **C** (부분 인접) |
| **컨테이너 관리**: ECR 이미지 빌드·관리, ECS·EKS·Fargate 배포 | **부분 인접.** `3-1.md` §컨테이너 이미지·ECR, `3-3.md` §이미지 태그, `3-4.md` §ECS 배포 전략, `4-2.md` EKS 프로브, `2-1.md` ECS 작업 역할·EKS Pod Identity. EKS·Fargate 배포 절차 중심의 노트는 없음 | **C** (부분 인접) |
| **신규 in-scope: Amazon Bedrock · Bedrock AgentCore · Amazon Q · Kiro** | Q Developer·Kiro는 `1-1.md`·`3-3.md`·`4-1.md`에 '제품 현황 메모'뿐, Bedrock은 Q Developer 설명문 1줄, AgentCore는 0건 | **C** |
| **신규 in-scope: AWS PrivateLink** | 인접 언급만: `4-2.md`(인터페이스 엔드포인트로 X-Ray 전송), `1-2.md`(Lambda 함수 URL은 PrivateLink 미지원) | **C** (부분 인접) |
| 신규 in-scope: Amazon Data Firehose | **대응 있음**: `1-1.md` §스트리밍, `1-2.md` §Firehose 변환, `4-2.md` 쿼터 | A급(재사용) |

---

## 4. 분류가 A여도 절(Skill) 단위로 손볼 곳

- **Amazon Q Developer 절** — `1-1.md`(Skill 1.1.11)·`3-3.md`(Skill 3.3.6): IDE 플러그인·유료 구독 2027-04-30 지원 종료, 신규 가입 2026-05-15 차단, 후속 Kiro(노트 `확인 필요` 1.1 #5·#6, 3.3 #2·#3, 4.1 #3). C03 예고의 'Amazon Q·Kiro' 신규 in-scope와 연결된다.
- **AWS Copilot 환경** — `3-3.md`(Skill 3.3.3): Copilot CLI 2026-06-12 지원 종료(3.3 #1·#13, 3.4 #18). C03에서 예시가 유지될지는 미확인.
- **프로파일링·추적** — `4-3.md`(Skill 4.3.2): 한·영 번역 불일치와 CodeGuru Profiler 현황 미확정(4.3 #1·#6). `4-2.md`·`4-3.md`: X-Ray SDK/Daemon 2026-02-25 유지보수 모드·OTel 권장(4.2 #1·#2, 4.3 #8).
- **ECS 배포 전략** — `3-4.md` §ECS: 내장 blue/green·linear/canary·NLB 지원은 C02 가이드(2024-12) 이후 기능(3.4 #2). C03의 ECS/EKS/Fargate 배포 예고와 접점.
- **Lambda 용어** — 전 노트 공통: 최신 Lambda 문서는 기존 함수를 "Event Function"(이전 명칭 Lambda function)으로 부르고 Managed Instances·MicroVMs·Web Functions·Durable functions를 따로 다룬다(1.2 #4·#5, 3.4 #3, 4.3 #2 외).
- **캐싱 중복** — `1-3.md` §캐싱(1.3.8)과 `4-3.md` §앱 수준 캐싱(4.3.6)이 ElastiCache·DAX를 함께 다룬다. 최적화 통합 시 한쪽으로 합칠 후보.
- **번호 충돌 경고** — C02 Task 2.3(민감 데이터) ≠ C03 Task 2.3(AI security, 신설). Task 번호가 아니라 **주제**로 매핑할 것.

---

## 5. 분포 요약

| 구분 | A | B | C |
|---|---|---|---|
| C02 Task 13개 | **6** (1.1·1.2·2.1·3.1·3.4·4.1) | **7** (1.3·2.2·2.3·3.2·3.3·4.2·4.3) | 0 |
| C03 예고 신설·확장 영역 6건 | 1 (Data Firehose — A급) | — | **5** (AI security Task·Bedrock/AgentCore/Q/Kiro 서비스 = 대응 없음 2건 / AI 보조 개발·컨테이너 관리·PrivateLink = 부분 인접 3건) |

## 6. 2026-10-27 가이드 공개 후 재확인 체크리스트

1. C03 가이드의 Task/Skill 목록·번호·Skill 수 — §1의 '개수 일치 추정'(1.3.1~1.3.4 / 2.2+2.3 / 3.2+3.3 / 4.2 / 4.3)이 맞는지 검증.
2. 도메인 이름·비중(블로그: 30/26/22/22, 도메인 3 "Testing and Deployment") 확인.
3. in-scope/out-of-scope 서비스 목록 개정(Bedrock·AgentCore·Q·Kiro·Data Firehose·PrivateLink 외 추가·삭제) 확인.
4. Skill 문구 속 서비스(SAM·Private CA·Copilot·Q Developer 등)의 변화 확인.
5. 개정 이력(버전·게시일)과 Emerging topics 절 유무 확인.
