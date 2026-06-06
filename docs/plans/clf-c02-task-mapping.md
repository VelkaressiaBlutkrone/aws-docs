# CLF-C02 Task/Skill 매핑표

출처: AWS Certified Cloud Practitioner (CLF-C02) 공식 Exam Guide v1.0
원문: https://d1.awsstatic.com/training-and-certification/docs-cloud-practitioner/AWS-Certified-Cloud-Practitioner_Exam-Guide.pdf
작성: 2026-06-05 (공식 PDF에서 직접 추출 — AI 초안, 본인 대조 검수 필요)
검수 상태: ☐ 미검수 (PDF 대조 후 체크)

시험: 65문항(채점 50 + 비채점 15) / 90분 / 합격 700/1000
커버리지 기준: **Task당 검증 문항 ≥5개** (CEO 플랜 E2/T10 기준)

| 진행 표기 | 의미 |
|---|---|
| 문서 ☐ | 해당 Task를 다루는 학습문서 작성 여부 |
| 문항 0/5 | 검증(verified) 문항 수 / 목표 |

---

## Domain 1: Cloud Concepts (24%)

### Task 1.1 — AWS 클라우드의 이점 정의 `clf-t1-1` · 문서 ☑ · 문항 6/6 ✅
- **Knowledge:** AWS 클라우드의 가치 제안
- **Skills:** 규모의 경제(비용 절감) / 글로벌 인프라의 이점(배포 속도, 글로벌 도달) / 고가용성·탄력성·민첩성의 장점

### Task 1.2 — AWS 클라우드 설계 원칙 식별 `clf-t1-2` · 문서 ☑ · 문항 6/6 ✅
- **Knowledge:** AWS Well-Architected Framework
- **Skills:** 6개 기둥 이해(운영 우수성, 보안, 안정성, 성능 효율, 비용 최적화, 지속 가능성) / 기둥 간 차이 식별

### Task 1.3 — 클라우드 마이그레이션의 이점과 전략 `clf-t1-3` · 문서 ☑ · 문항 5/5 ✅
- **Knowledge:** 클라우드 도입 전략 / 마이그레이션 여정 지원 리소스
- **Skills:** AWS CAF의 이점(비즈니스 위험 감소, ESG 개선, 매출·운영 효율 증가) / 적절한 마이그레이션 전략 식별(DB 복제, AWS Snowball)

### Task 1.4 — 클라우드 경제학 개념 `clf-t1-4` · 문서 ☑ · 문항 6/6 ✅
- **Knowledge:** 클라우드 경제학 요소 / 클라우드 이전의 비용 절감
- **Skills:** 고정비 vs 변동비 / 온프레미스 비용 / 라이선스 전략 차이(BYOL vs 포함) / rightsizing / 자동화 이점(CloudFormation) / 관리형 서비스 식별(RDS, ECS, EKS, DynamoDB)

## Domain 2: Security and Compliance (30%)

### Task 2.1 — 공동 책임 모델 `clf-t2-1` · 문서 ☑ · 문항 5/5 ✅
- **Knowledge:** AWS 공동 책임 모델
- **Skills:** 모델 구성요소 / 고객 책임 / AWS 책임 / 공유 책임 / 서비스에 따른 책임 이동(RDS vs Lambda vs EC2)

### Task 2.2 — 보안·거버넌스·컴플라이언스 개념 `clf-t2-2` · 문서 ☑ · 문항 9/9 ✅
- **Knowledge:** 컴플라이언스·거버넌스 개념 / 클라우드 보안의 이점(암호화) / 보안 로그 위치
- **Skills:** 컴플라이언스 정보 위치(AWS Artifact) / 지역·산업별 요구(AWS Compliance) / 리소스 보호 서비스(Inspector, Security Hub, GuardDuty, Shield) / 암호화 옵션(전송 중/저장 시) / 거버넌스 서비스(CloudWatch 모니터링, CloudTrail·Audit Manager·Config 감사) / 서비스별 컴플라이언스 차이

### Task 2.3 — 접근 관리 기능 식별 `clf-t2-3` · 문서 ☑ · 문항 7/7 ✅
- **Knowledge:** IAM / 루트 사용자 보호의 중요성 / 최소 권한 원칙 / IAM Identity Center(SSO)
- **Skills:** 액세스 키·암호 정책·자격증명 저장(Secrets Manager, Systems Manager) / 인증 방법(MFA, IAM Identity Center, 교차 계정 역할) / 최소 권한에 따른 그룹·사용자·정책 정의 / 루트 전용 작업 식별 / 루트 보호 방법 / 자격증명 유형(페더레이션)

### Task 2.4 — 보안 구성요소·리소스 식별 `clf-t2-4` · 문서 ☑ · 문항 6/6 ✅
- **Knowledge:** AWS 보안 기능 / 보안 문서
- **Skills:** 보안 기능·서비스(보안 그룹, 네트워크 ACL, WAF) / Marketplace 서드파티 보안 제품 / 보안 정보 위치(Knowledge Center, Security Blog) / 보안 이슈 식별 서비스(Trusted Advisor)

## Domain 3: Cloud Technology and Services (34%)

### Task 3.1 — 배포·운영 방법 정의 `clf-t3-1` · 문서 ☑ · 문항 6/6 ✅
- **Knowledge:** 프로비저닝·운영 방식 / 서비스 접근 방식 / 배포 모델 / 연결 옵션
- **Skills:** 프로그래밍 접근(API, SDK, CLI) vs 콘솔 vs IaC / 일회성 vs 반복 프로세스 / 배포 모델(클라우드·하이브리드·온프레미스) / 연결 옵션(VPN, Direct Connect, 공용 인터넷)

### Task 3.2 — 글로벌 인프라 정의 `clf-t3-2` · 문서 ☑ · 문항 6/6 ✅
- **Knowledge:** 리전·AZ·엣지 로케이션 / 고가용성 / 멀티 리전 / Wavelength·Local Zones
- **Skills:** 리전-AZ-엣지 관계 / 멀티 AZ 고가용성 / AZ는 단일 장애점 비공유 / 멀티 리전 사용 시점(DR, 비즈니스 연속성, 지연시간, 데이터 주권) / 엣지의 이점(CloudFront, Global Accelerator)

### Task 3.3 — 컴퓨팅 서비스 식별 `clf-t3-3` · 문서 ☑ · 문항 7/7 ✅
- **Skills:** EC2 인스턴스 유형 용도(컴퓨팅/스토리지 최적화) / 컨테이너(ECS, EKS) / 서버리스(Fargate, Lambda) / Auto Scaling=탄력성 / 로드 밸런서 목적

### Task 3.4 — 데이터베이스 서비스 식별 `clf-t3-4` · 문서 ☑ · 문항 6/6 ✅
- **Knowledge:** DB 서비스 / DB 마이그레이션
- **Skills:** EC2 호스팅 vs 관리형 DB / 관계형(RDS, Aurora) / NoSQL(DynamoDB) / 인메모리 / 마이그레이션 도구(DMS, SCT)

### Task 3.5 — 네트워크 서비스 식별 `clf-t3-5` · 문서 ☑ · 문항 6/6 ✅
- **Skills:** VPC 구성요소(서브넷, 게이트웨이) / VPC 보안(NACL, 보안 그룹) / Route 53 목적 / 엣지 서비스(CloudFront, Global Accelerator) / 연결 옵션(VPN, Direct Connect)

### Task 3.6 — 스토리지 서비스 식별 `clf-t3-6` · 문서 ☑ · 문항 7/7 ✅
- **Skills:** 객체 스토리지 용도 / S3 스토리지 클래스 차이 / 블록 스토리지(EBS, 인스턴스 스토어) / 파일 서비스(EFS, FSx) / 캐시 파일 시스템(Storage Gateway) / 수명 주기 정책 / AWS Backup

### Task 3.7 — AI/ML·분석 서비스 식별 `clf-t3-7` · 문서 ☑ · 문항 7/7 ✅
- **Skills:** AI/ML 서비스와 역할(SageMaker, Lex, Kendra) / 분석 서비스(Athena, Kinesis, Glue, QuickSight)

### Task 3.8 — 기타 범위 내 서비스 식별 `clf-t3-8` · 문서 ☑ · 문항 6/6 ✅
- **Knowledge:** 앱 통합(EventBridge, SNS, SQS) / 비즈니스 앱(Connect, SES) / 고객 지원(Activate, IQ, AMS, Support) / 개발자 도구(AppConfig, Cloud9, CloudShell, CodeArtifact/Build/Commit/Deploy/Pipeline/Star, X-Ray) / 최종 사용자 컴퓨팅(AppStream 2.0, WorkSpaces) / 프런트엔드·모바일(Amplify, AppSync) / IoT(IoT Core, Greengrass)
- **Skills:** 메시지·알림 서비스 선택 / 비즈니스 앱 서비스 선택 / 지원 옵션 선택 / 개발·배포·트러블슈팅 도구 식별 / VM 출력 표시 서비스 / 프런트엔드·모바일 서비스 / IoT 관리 서비스

## Domain 4: Billing, Pricing, and Support (12%)

### Task 4.1 — 요금 모델 비교 `clf-t4-1` · 문서 ☑ · 문항 6/6 ✅
- **Knowledge:** 컴퓨팅 구매 옵션(On-Demand, RI, Spot, Savings Plans, Dedicated Hosts/Instances, Capacity Reservations) / 데이터 전송 요금 / 스토리지 옵션·계층
- **Skills:** 구매 옵션 비교·선택 시점 / RI 유연성 / Organizations에서의 RI 동작 / 수신·발신 데이터 전송 비용(리전 간, 리전 내) / 스토리지 계층별 요금

### Task 4.2 — 결제·예산·비용 관리 리소스 `clf-t4-2` · 문서 ☑ · 문항 6/6 ✅
- **Knowledge:** 결제 지원·정보 / 서비스 요금 정보 / AWS Organizations / 비용 할당 태그
- **Skills:** Budgets·Cost Explorer·Billing Conductor 용도 / Pricing Calculator / Organizations 통합 결제·비용 할당 / 비용 할당 태그와 보고서(Cost and Usage Report)

### Task 4.3 — 기술 리소스·Support 옵션 식별 `clf-t4-3` · 문서 ☑ · 문항 5/5 ✅
- **Knowledge:** 공식 웹사이트 리소스·문서 / Support 플랜 / APN(ISV, SI) 역할 / Support Center
- **Skills:** 백서·블로그·문서 위치 / 기술 리소스 식별(Prescriptive Guidance, Knowledge Center, re:Post) / Support 옵션 식별(고객 서비스·커뮤니티, Developer, Business, Enterprise)

---

## 커버리지 집계

| Domain | 가중치 | Tasks | 문서 | 검증 문항 | 목표 |
|--------|-------|-------|------|----------|------|
| 1 Cloud Concepts | 24% | 4 | 4/4 ✅ | 23 | ≥20 ✅ |
| 2 Security & Compliance | 30% | 4 | 4/4 | 27 | ≥20 |
| 3 Technology & Services | 34% | 8 | 8/8 ✅ | 51 | ≥40 ✅ |
| 4 Billing, Pricing & Support | 12% | 3 | 3/3 ✅ | 17 | ≥15 ✅ |
| **합계** | 100% | **19** | **19/19 🎉** | **118** | **≥95** ✅ (스트레치 130에 근접) |

> 이 표가 `src/content/clf/examGuide.ts`(T8)의 원본 데이터다. Task ID(`clf-t1-1` 형식)는 문항의 `examGuideTaskId`로 그대로 사용한다.
> 부록: 공식 가이드 끝의 in-scope 서비스 전체 목록은 문항 보기(선택지) 구성 시 참조.
> ⚠️ 스택 정정: 콘텐츠 레이어는 이제 Flutter 자산(`flutter_app/assets/content/clf/`)이다. 위의 `src/content/...`는 철거된 옛 Vite 경로(역사적 참조).

## 진척 로그

- **2026-06-06 — 첫 verified 배치 완료: `clf-t2-1` (공동 책임 모델).**
  - 산출물: `flutter_app/assets/content/clf/t2-1.md`(학습문서) + `t2-1.questions.json`(검증 문항 5/5).
  - 규율: 문항마다 공식 AWS 출처 URL 기록(verified 게이트) + 독립 서브에이전트 **AI 역대조 통과(5/5 CORRECT, 수정 0)**.
  - 출처: 공동 책임 모델 페이지(ko/en), Security in Amazon RDS, Security in AWS Lambda, AWS Data Center Controls(NIST 800-88), CLF-C02 공식 가이드.
  - ⏱ **측정:** 1문항 AI 작성 ≈ **55초**(4지선다+정답/오답해설+출처 4개 대조 포함). 역대조 ≈ 배치당 66초(문항당 ~13초 균등). → 병목은 작성이 아니라 **사람 검수**이며, 그 시간은 본인이 실제 리뷰할 때 측정해야 진짜 분당 단가가 나온다(플레이북 가설과 일치).
  - 다음: 이 2파일이 나머지 18개 Task의 복제 템플릿.

- **2026-06-06 (세션 2) — 학습 루프 #1(기반) 구현·main 병합·배포.** 렌더러(Markdown 섹션 뷰) + 퀴즈 러너(정답/오답해설·점수·문항별 복기) + localStorage 이력(D14) + CLF 상세 진입 섹션. `flutter analyze` 무이슈 / 테스트 11 / `build web` 성공 / opus 최종 리뷰 반영. 설계·계획: `docs/designs/2026-06-06-clf-learning-loop-foundation-spec.md`, `docs/plans/2026-06-06-clf-learning-loop-foundation-plan.md`. **렌더러 완성 → 이후 검증 콘텐츠는 추가 즉시 사이트 노출.** 다음 세션: (1) 다음 CLF Task 콘텐츠 → (2) 하위 프로젝트 #2(타이머·플래그).

- **2026-06-06 (세션 3) — 두 번째 verified 배치 완료: `clf-t2-3` (접근 관리/IAM).**
  - 산출물: `flutter_app/assets/content/clf/t2-3.md`(학습문서) + `t2-3.questions.json`(검증 문항 **7/7**) + `lib/data/content_index.dart` 등록.
  - 커버한 Task 2.3 Skill: 루트 전용 작업 식별 / 루트 보호 / 최소 권한 / MFA(인증) / IAM Identity Center·페더레이션 / 그룹·사용자·정책 / 자격증명 저장(Secrets Manager). (Task 2.1보다 표면이 넓어 5개가 아닌 7문항.)
  - 규율: 문항·문서 작성 전 **공식 AWS 문서 9종을 실제로 페치해 사실 대조**(verified 게이트 honor) — IAM 개요/자격증명(id)/루트 사용자·루트 전용 작업/보안 모범 사례/MFA/암호 정책/IAM Identity Center(리네이밍 2022-07-26)/Secrets Manager/CLF 공식 가이드. 독립 서브에이전트 **AI 역대조 = 7/7 CORRECT, 수정 강제 0건**(해설 정밀도 1건만 보강: Q3 명시적 vs 암묵적 Deny).
  - 검증: `flutter analyze` 무이슈 / `flutter test` 11 통과(런타임 verified 게이트·QuestionBank 파싱 포함). 렌더러가 이미 있어 main push 시 사이트 즉시 노출.
  - 커버리지: **1/19 → 2/19 Task, 검증 문항 5 → 12.**

- **2026-06-06 (세션 4) — 세 번째·네 번째 verified 배치 완료: `clf-t2-2`(보안·거버넌스·컴플라이언스, 9문항) + `clf-t2-4`(보안 구성요소·리소스, 6문항) → 도메인 2 완성(4/4).**
  - 산출물: `t2-2.md`+`t2-2.questions.json`(9), `t2-4.md`+`t2-4.questions.json`(6), `lib/data/content_index.dart` 2줄 등록.
  - 커버한 Task 2.2: 탐지 3종(GuardDuty=위협/Inspector=취약점/Macie=민감데이터) · Security Hub(CSPM) 집계 · Shield(DDoS Standard 무료/Advanced 유료) · 암호화(KMS, 전송/저장) · 감사 3종(CloudTrail=누가/Config=구성/CloudWatch=성능) · Artifact vs Audit Manager. Task 2.4: 보안그룹(인스턴스·stateful·allow전용) vs NACL(서브넷·stateless·allow+deny) · WAF(L7 SQLi/XSS) · Trusted Advisor · Marketplace 서드파티 · 정보 위치(Knowledge Center/Security Blog/re:Post).
  - 규율: 공식 AWS 문서 16종을 실제 페치해 사실 대조(verified 게이트 honor). 독립 서브에이전트 **AI 역대조 = t2-2 9/9 + t2-4 6/6 CORRECT, 강제 수정 0건**(t2-2 q5 출처 1건 선택 보강만). 발견·정정: Security Hub→CSPM 리네이밍 병기, Audit Manager '신규 고객 등록 중단' 각주.
  - 검증: `flutter analyze` 무이슈 / `flutter test` 21 통과 / `flutter build web --release --base-href /aws-docs/` 성공(exit 0).
  - 커버리지: **2/19 → 4/19 Task, 검증 문항 12 → 27. 도메인 2(보안·규정 준수, 30%) 4/4 완성.**

- **2026-06-06 (세션 5) — 다섯 번째·여섯 번째 verified 배치: `clf-t3-2`(글로벌 인프라, 6문항) + `clf-t3-3`(컴퓨팅, 7문항) → 도메인 3(34%) 착수(2/8).**
  - 산출물: `t3-2.md`+`t3-2.questions.json`(6), `t3-3.md`+`t3-3.questions.json`(7), `content_index.dart` 2줄 등록.
  - 커버: t3-2 리전·AZ·엣지 관계 · 멀티AZ 고가용성 · 리전 격리/데이터 주권 · CloudFront(CDN 캐싱) vs Global Accelerator(고정 IP 라우팅) · Local Zones/Wavelength/Outposts. t3-3 EC2(가상 서버·인스턴스 유형) · ECS vs EKS(Kubernetes) · 서버리스(Lambda 함수/Fargate 컨테이너) · Auto Scaling(탄력성) · ELB(분산, ALB L7/NLB L4).
  - 규율: 공식 AWS 문서 11종 실페치 대조. 독립 서브에이전트 역대조 **t3-2 6/6 + t3-3 7/7 CORRECT, 정식 문항 수정 0건**(t3-2 학습문서 자가점검 "한 자릿수 ms" 과장만 "저지연"으로 완화).
  - 검증: `flutter analyze` 무이슈 / `flutter test` 21 / `build web --release` green(exit 0).
  - 커버리지: **4/19 → 6/19 Task, 검증 문항 27 → 40. 도메인 3(클라우드 기술·서비스, 34%) 2/8 착수.**

- **2026-06-06 (세션 6) — 일곱·여덟 번째 verified 배치: `clf-t3-6`(스토리지, 7문항) + `clf-t3-4`(데이터베이스, 6문항) → 도메인 3 4/8.**
  - 산출물: `t3-6.md`+`t3-6.questions.json`(7), `t3-4.md`+`t3-4.questions.json`(6), `content_index.dart` 2줄 등록.
  - 커버: t3-6 객체(S3)·블록(EBS)·파일(EFS/FSx) 구분 · S3 클래스(Intelligent-Tiering vs Glacier Deep Archive) · Lifecycle · Storage Gateway(하이브리드) · AWS Backup(중앙 백업). t3-4 EC2 vs RDS 책임 · RDS/Aurora(관계형) · DynamoDB(NoSQL) · ElastiCache(인메모리) · DMS/SCT(마이그레이션).
  - 규율: 공식 AWS 문서 11종 실페치 대조. 독립 서브에이전트 역대조 **t3-6 7/7 + t3-4 6/6 CORRECT, 수정 0건**.
  - 검증: `flutter analyze` 무이슈 / `flutter test` 21 / `build web --release` green(exit 0).
  - 커버리지: **6/19 → 8/19 Task, 검증 문항 40 → 53. 도메인 3 4/8.**

- **2026-06-06 (세션 7) — 아홉·열 번째 verified 배치: `clf-t3-5`(네트워킹, 6문항) + `clf-t3-1`(배포·운영, 6문항) → 도메인 3 6/8.**
  - 산출물: `t3-5.md`+`t3-5.questions.json`(6), `t3-1.md`+`t3-1.questions.json`(6), `content_index.dart` 2줄 등록(taskId 정렬 t3-1~t3-6).
  - 커버: t3-5 VPC 구성요소(서브넷·인터넷 게이트웨이·라우트 테이블)·Route 53(DNS)·Direct Connect(전용 회선) vs Site-to-Site VPN(인터넷 IPsec). t3-1 콘솔/CLI/SDK/IaC(CloudFormation)·일회성 vs 반복·배포 모델(하이브리드)·연결 옵션.
  - 규율: 공식 문서 6종 실페치 대조. 독립 서브에이전트 역대조 **t3-5 6/6 + t3-1 6/6 CORRECT**. t3-1 **출처 정합성 2건 보강**(q3 SDK 정의 출처, q4 배포 모델→CLF 가이드) — 정답은 정확하나 출처가 진술을 직접 뒷받침하도록 교체(verified 게이트 엄격 적용).
  - 검증: `flutter analyze` 무이슈 / `flutter test` 21 / `build web --release` green(exit 0).
  - 커버리지: **8/19 → 10/19 Task, 검증 문항 53 → 65.** (검증 문항 수가 CLF 실제 시험 65문항과 같아짐 — 절반 넘김.)

- **2026-06-06 (세션 8) — 열한·열두 번째 verified 배치: `clf-t3-7`(AI/ML·분석, 7문항) + `clf-t3-8`(기타 서비스, 6문항) → 🎉 도메인 3(34%) 완성(8/8).**
  - 산출물: `t3-7.md`+`t3-7.questions.json`(7), `t3-8.md`+`t3-8.questions.json`(6), `content_index.dart` 2줄 등록.
  - 커버: t3-7 AI/ML(SageMaker·Lex·Kendra) · 분석(Athena·Kinesis·Glue·QuickSight). t3-8 앱 통합(SNS·SQS·EventBridge) · WorkSpaces(DaaS) · IoT Core.
  - 규율: 공식 AWS 문서 12종 실페치 대조. 독립 서브에이전트 역대조 **t3-7 7/7 + t3-8 6/6 CORRECT**. 발견·정정: SageMaker→**SageMaker AI**(2024-12), QuickSight→**Amazon Quick(Sight)** 리네이밍 병기 + 출처 표기 보정(q7·q6).
  - 검증: `flutter analyze` 무이슈 / `flutter test` 21 / `build web --release` green(exit 0).
  - 커버리지: **10/19 → 12/19 Task, 검증 문항 65 → 78. 도메인 3(34%) 8/8 완성** → 도메인 2(30%) + 3(34%) = **시험 비중 64% 완성**.

- **2026-06-06 (세션 9) — 열셋·열넷 번째 verified 배치: `clf-t1-1`(클라우드 이점, 6문항) + `clf-t1-2`(Well-Architected, 6문항) → 도메인 1(24%) 착수(2/4).**
  - 산출물: `t1-1.md`+`t1-1.questions.json`(6), `t1-2.md`+`t1-2.questions.json`(6), `content_index.dart` 2줄 등록(맨 앞, 도메인 1).
  - 커버: t1-1 클라우드 정의(온디맨드·종량 과금) · 4대 이점(민첩성·탄력성·비용 절감/규모의 경제·글로벌 배포) · 고가용성 vs 탄력성 vs 민첩성 구분. t1-2 Well-Architected **6대 기둥**(운영 우수성·보안·안정성·성능 효율성·비용 최적화·지속 가능성) · 감사 아님 · 무료 WA Tool.
  - 규율: 공식 AWS 문서 5종 실페치 대조(각 기둥 페이지 포함). 독립 서브에이전트 역대조 **t1-1 6/6 + t1-2 6/6 CORRECT**. t1-1 **출처 정합성 2건 보강**(q5 'deploy in minutes' 1차 출처, q6 고가용성 근거→글로벌 인프라 페이지).
  - 검증: `flutter analyze` 무이슈 / `flutter test` 21 / `build web --release` green(exit 0).
  - 커버리지: **12/19 → 14/19 Task, 검증 문항 78 → 90.** (목표 ≥95의 95% — 거의 도달.)

- **2026-06-06 (세션 10) — 열다섯·열여섯 번째 verified 배치: `clf-t1-3`(마이그레이션, 5문항) + `clf-t1-4`(클라우드 경제학, 6문항) → 🎉 도메인 1(24%) 완성(4/4).**
  - 산출물: `t1-3.md`+`t1-3.questions.json`(5), `t1-4.md`+`t1-4.questions.json`(6), `content_index.dart` 2줄 등록.
  - 커버: t1-3 AWS CAF(도입 여정·이점) · Snowball(오프라인 대량 전송) · DMS vs Snowball · CAF vs Well-Architected. t1-4 고정비 vs 변동비 · Compute Optimizer(rightsizing) · BYOL · CloudFormation 자동화 · 관리형 서비스(TCO).
  - 규율: 공식 AWS 문서 8종 실페치 대조. 독립 서브에이전트 역대조 **t1-3 5/5 + t1-4 6/6 CORRECT**. 정직성 보강: Snowball '신규 고객 중단' 메모·"페타바이트"→"테라바이트급" 완화; **출처 정합성 보강**(t1-4 q3 BYOL→Marketplace 용어 근거, q1 온프레 비용→RDS 책임표).
  - 검증: `flutter analyze` 무이슈 / `flutter test` 21 / `build web --release` green(exit 0).
  - 커버리지: **14/19 → 16/19 Task, 검증 문항 90 → 101. 🎯 목표 ≥95 달성! 도메인 1·2·3 완성** → 남은 = 도메인 4(12%, 3 Task)뿐.

- **2026-06-06 (세션 11) — 🏁 CLF 19/19 완주: `clf-t4-1`(요금 모델, 6) + `clf-t4-2`(결제·예산, 6) + `clf-t4-3`(Support·리소스, 5) → 도메인 4 완성(3/3), CLF 전체 19/19.**
  - 산출물: t4-1·t4-2·t4-3 (각 md+questions.json), `content_index.dart` 3줄 등록.
  - 커버: t4-1 구매 옵션 6종(On-Demand·Savings Plans·RI·Spot·Dedicated Hosts·Capacity Reservations)·데이터 전송·스토리지 계층. t4-2 Pricing Calculator(구축 전 추정)·Cost Explorer(발생 후 분석)·Budgets(알림)·Organizations(통합 결제·SCP)·비용 할당 태그. t4-3 Support 플랜(Basic/Developer/Business/Enterprise)·기술 리소스(re:Post·Knowledge Center·Prescriptive Guidance)·APN.
  - 규율: 공식 AWS 문서 6종 실페치 대조. 독립 서브에이전트 역대조 **t4-1 6/6 + t4-2 6/6 + t4-3 5/5 CORRECT**. 정직성: Support 플랜 재편(2027 단종) 메모; 출처 보강: t4-1 Spot '최대 90%'→제품 페이지, q4 데이터 전송 출처 보강.
  - 검증: `flutter analyze` 무이슈 / `flutter test` 21 / `build web --release` green(exit 0).
  - 커버리지: **16/19 → 19/19 🎉 CLF 콘텐츠 완주. 검증 문항 101 → 118(목표 ≥95 초과, 스트레치 130 근접). 4개 도메인 모두 완성.**
