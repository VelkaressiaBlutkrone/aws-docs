# 00-overview — AWS Certified Solutions Architect – Associate (SAA-C03) 시험 메타·공식 가이드 실측

- **조회일**: 2026-10-17(최초 조사) · 2026-10-19(재개 후 재확인). 각 사실 옆의 URL은 모두 이번 조사에서 실제로 열람한 공식 페이지다.
- **범위·원칙**: 공식 AWS 페이지(docs.aws.amazon.com · aws.amazon.com · repost.aws knowledge-center)와 레포 읽기 전용 파일만 사용. 시험 덤프·문제 유출 사이트는 접근하지 않았다. 확인하지 못한 것은 본문에 쓰지 않고 `99-gaps.md`에 "확인 필요"로 남겼다. 3자 자료는 `[3자]`로 표시(보조용).
- **이 폴더의 구성**

| 파일 | 내용 |
|---|---|
| `00-overview.md` | (이 파일) 시험 메타 실측·가이드 버전/개정 상태·Task 구성·레포 JSON 대조·서비스 범위·명칭/수명주기 변화 |
| `tasks/<n-m>.md` ×14 | 공식 Task별 연구 파일(공식 원문 ko/en, 핵심 개념, 출제 패턴, 함정, 사실표 F-xx[출처 URL], 자가 점검 재료, 출처 목록) |
| `98-existing-gap.md` | 기존 학습문서 `flutter_app/assets/content/saa/saa-t*.md` 24개 ↔ 공식 Task별 차이(누락·구식·오류·의심·중복) — **수정은 하지 않음** |
| `99-gaps.md` | 상충·불확실·확인 필요 목록과 레포 JSON 수정 제안 |

---

## 1. 시험 메타 (실측)

| 항목 | 값 | 출처 | 비고 |
|---|---|---|---|
| 공식 자격증명(en) | **AWS Certified Solutions Architect - Associate (SAA-C03)** | 웹 가이드 en | |
| 공식 자격증명(ko) | **AWS Certified Solutions Architect - Associate(SAA-C03)** | 웹 가이드 ko | 괄호 앞 공백 차이만 있음 |
| 카테고리·수준 | Associate | 인증 페이지 | JSON `level: "Associate"`와 일치 |
| 대상 | Solutions Architect 역할 수행자. AWS Well-Architected Framework 기반 솔루션 설계 능력을 검증 | 웹 가이드 | 현재·미래 요구를 충족하는 설계, 안전·복원·고성능·비용 최적 아키텍처, 기존 솔루션 검토·개선 결정 |
| 권장 경력 | AWS 서비스로 클라우드 솔루션을 설계한 실무 **1년 이상** | 웹 가이드·인증 페이지 | 실제로는 IT 경력 1~3년 응시자도 준비 가능하다고 인증 페이지가 서술 |
| **문항 수** | 총 **65문항 = 채점 50 + 비채점 15** | 웹 가이드("50 questions that affect your score", "15 unscored") · 인증 페이지("65 questions") | 비채점 문항은 시험에서 식별되지 않음. JSON `scoredQuestions: 50`·`unscoredQuestions: 15`와 일치 |
| 문항 유형 | 선다형(정답 1 + 오답 3) · 복수 응답형(5개 이상 중 2개 이상 정답) | 웹 가이드 | 무응답은 오답 처리, **추측 감점 없음** |
| **시험 시간** | **130분** | 인증 페이지("Exam duration 130 minutes") | **웹 가이드 페이지에는 시간 표기가 없음** — 시간은 인증 페이지에서만 확인. JSON `durationMinutes: 130`과 일치 |
| **합격 기준** | 보고 점수 **100–1,000** 변환 점수, **합격 최소 720** | 웹 가이드 | 합격/불합격 판정, 최소 표준은 AWS 전문가가 설정. JSON `passingScore: 720`과 일치 |
| 채점 모델 | **보상(compensatory) 점수 모델** — 섹션별 합격 불필요, 전체 시험만 합격하면 됨 | 웹 가이드 | 섹션별 성적 분류표는 참고용(주의해서 해석하라고 안내) |
| **도메인과 비중**(채점 콘텐츠 기준) | D1 보안 30% · D2 복원력 26% · D3 고성능 24% · D4 비용 최적화 20% | 웹 가이드 | JSON `weightPct`와 일치. 비중이 큰 섹션이 문항 수도 더 많음 |
| 응시료 | 150 USD(환율 등은 별도 가격 페이지) | 인증 페이지 | |
| 응시 방식 | Pearson VUE 시험장 또는 온라인 감독 | 인증 페이지 | |
| 제공 언어 | 영어·프랑스어(프랑스)·이탈리아어·일본어·**한국어**·포르투갈어(브라질)·스페인어(중남미)·스페인어(스페인)·중국어 간체·중국어 번체 | 인증 페이지 | **이탈리아어 시험은 2026-12-31 이후 종료**(인증 페이지 각주) |
| 자격 유효기간·재인증 | 3년. 최신 버전 시험 합격 또는 Solutions Architect – Professional 취득으로 재인증 | 인증 페이지 | 기존 자격 보유 시 다음 시험 50% 할인 |
| 서비스 약칭 | 읽기 부담을 줄이려 일부 서비스를 **공식 약칭**으로 표기(예: Amazon SNS). 시험 중 Help에서 약칭 목록 제공 | 웹 가이드 "Mentions of AWS Services", 인증 페이지 | 약어가 풀리지 않는 공식 명칭도 있음(예: Amazon API Gateway, Amazon EMR) |
| 출제 기술·개념 범주(비가중) | Compute · Cost management · Database · Disaster recovery · High performance · Management and governance · Microservices and component delivery · Migration and data transfer · Networking, connectivity, and content delivery · Resiliency · Security · Serverless and event-driven design principles · Storage | 웹 가이드 "Technologies and Concepts" | 목록의 순서·배치는 비중과 무관하다고 명시 |

**출처 URL**
- 웹 가이드(en): https://docs.aws.amazon.com/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
- 웹 가이드(ko): https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html (접속 시 `…/solutions-architect-associate-03.md`로 리다이렉트됨)
- 도메인 페이지(en/ko, 번호 1~4): `…/solutions-architect-associate-03-domain{1,2,3,4}.html` (en: https://docs.aws.amazon.com/aws-certification/latest/solutions-architect-associate-03/ · ko: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/)
- 인증 페이지: https://aws.amazon.com/certification/certified-solutions-architect-associate/
- 기술·개념: …/saa-technologies-concepts.html · 서비스 언급: …/saa-service-mentions.html · 범위 내/외 서비스: …/saa-03-in-scope-services.html · …/saa-03-out-of-scope-services.html

---

## 2. 공식 가이드 버전·발행일·개정 상태

| 항목 | 실측 내용 | 출처·한계 |
|---|---|---|
| 웹 가이드(현행 정본) | `…/latest/solutions-architect-associate-03/…` — **페이지에 버전 번호·발행일이 표기되어 있지 않음**(날짜 없이 "latest" 경로로 제공). ko 번역 병행 제공 | 웹 가이드 en/ko 직접 열람 |
| 시험 버전 발효 | SAA-C03은 **2022-08-30**에 갱신("updated as of August 30, 2022"). 이전 콘텐츠 개요의 Task 중 90% 이상을 유지, **신규 Task는 3.5(고성능 데이터 수집 및 변환)** 하나 | https://aws.amazon.com/blogs/training-and-certification/aws-certified-solutions-architect-associate-exam-updated-to-align-with-latest-trends-and-innovations/ |
| 레거시 PDF 가이드 | https://d1.awsstatic.com/training-and-certification/docs-sa-assoc/AWS-Certified-Solutions-Architect-Associate_Exam-Guide.pdf — **PDF 메타데이터 CreationDate/ModDate = 2023-09-25**(WebFetch로 확인, 작성도구 Word 2019), 포함된 설문 링크 `course_id=SAA-C03` | 이번 세션 확인 범위는 메타데이터까지. **본문의 "Version 1.1 SAA-C03" 라벨은 이전 세션 기록**이며 이번 세션에서는 PDF 렌더 도구(poppler)가 없어 본문 재확인 불가 → `99-gaps.md` |
| 개정 상태(2026-10-19 기준) | 인증 페이지가 **여전히 SAA-C03을 현행 시험**으로 표기. 후속 버전(SAA-C04 등) 공지는 확인하지 못함. 2026-09 인증 업데이트 공지(MLA-C02 베타, SAP-C03 등록 2026-10-27·GA 2026-11-17·SAP-C02 종료 2026-11-16, DVA-C03)에는 **SAA가 포함되어 있지 않음** | https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ — "공지에 없다"는 사실만 기록하며 향후 일정은 단정하지 않음 |
| 가이드 본문에서 관찰한 현행 표기 | Task 3.5의 BI 서비스 표기는 **Amazon Quick**(구 QuickSight). In-Scope 목록은 **"Amazon Aurora Serverless"**(구 명칭)와 **"AWS Snow Family"**를 여전히 포함 | 웹 가이드 도메인 3·In-Scope 목록 — 서비스 자체의 최신 상태는 §6 참조 |

> **메모**: 웹 가이드에는 발행일이 없으므로 "공식 가이드의 최신 개정 시점"을 날짜로 단정할 수 없다. 이 연구의 기준은 *2026-10-19에 열람한 웹 가이드의 내용*이다. 가이드 갱신 여부를 추적하려면 §4의 JSON 대조(189개 항목)를 재실행하는 것이 가장 확실하다.

---

## 3. 도메인·Task 구성 (14 Tasks · Knowledge 107 · Skills 82)

| 도메인(비중) | Task | 한글명 | 영문명 | K / S | 연구 파일 | 대응 기존 학습문서 |
|---|---|---|---|---|---|---|
| **D1 보안(30%)** | 1.1 | AWS 리소스에 대한 보안 액세스 설계 | Design secure access to AWS resources | 5 / 6 | `tasks/1-1.md` | `saa-t1-1`·`t1-2` |
| | 1.2 | 안전한 워크로드 및 애플리케이션 설계 | Design secure workloads and applications | 6 / 4 | `tasks/1-2.md` | `saa-t1-3`·`t1-4` |
| | 1.3 | 적합한 데이터 보안 제어 결정 | Determine appropriate data security controls | 4 / 7 | `tasks/1-3.md` | `saa-t1-5` |
| **D2 복원력(26%)** | 2.1 | 확장 가능하고 느슨하게 결합된 아키텍처 설계 | Design scalable and loosely coupled architectures | 16 / 7 | `tasks/2-1.md` | `saa-t2-1`·`t2-2`·`t2-3`(부분) |
| | 2.2 | 고가용성 및/또는 내결함성 아키텍처 설계 | Design highly available and/or fault-tolerant architectures | 12 / 8 | `tasks/2-2.md` | `saa-t2-3`·`t2-4`·`t2-5` |
| **D3 고성능(24%)** | 3.1 | 고성능 및/또는 확장 가능한 스토리지 솔루션 결정 | Determine high-performing and/or scalable storage solutions | 3 / 2 | `tasks/3-1.md` | `saa-t3-1`·`t3-2` |
| | 3.2 | 고성능의 탄력적인 컴퓨팅 솔루션 설계 | Design high-performing and elastic compute solutions | 6 / 4 | `tasks/3-2.md` | `saa-t3-3`·`t3-4` |
| | 3.3 | 고성능 데이터베이스 솔루션 결정 | Determine high-performing database solutions | 8 / 5 | `tasks/3-3.md` | `saa-t3-5`·`t3-6` |
| | 3.4 | 고성능 및/또는 확장 가능한 네트워크 아키텍처 결정 | Determine high-performing and/or scalable network architectures | 4 / 4 | `tasks/3-4.md` | `saa-t3-7`·`t3-8` |
| | 3.5 | 고성능 데이터 수집 및 변환 솔루션 결정 | Determine high-performing data ingestion and transformation solutions | 7 / 7 | `tasks/3-5.md` | `saa-t3-9` |
| **D4 비용 최적화(20%)** | 4.1 | 비용에 최적화된 스토리지 솔루션 설계 | Design cost-optimized storage solutions | 11 / 10 | `tasks/4-1.md` | `saa-t4-1`(+`t4-5` 공통) |
| | 4.2 | 비용에 최적화된 컴퓨팅 솔루션 설계 | Design cost-optimized compute solutions | 9 / 6 | `tasks/4-2.md` | `saa-t4-2`(+`t4-5`) |
| | 4.3 | 비용에 최적화된 데이터베이스 솔루션 설계 | Design cost-optimized database solutions | 9 / 5 | `tasks/4-3.md` | `saa-t4-3`(+`t4-5`) |
| | 4.4 | 비용에 최적화된 네트워크 아키텍처 설계 | Design cost-optimized network architectures | 7 / 7 | `tasks/4-4.md` | `saa-t4-4`(+`t4-5`) |

- 합계: Knowledge 5+6+4+16+12+3+6+8+4+7+11+9+9+7 = **107**, Skills 6+4+7+7+8+2+4+5+4+7+10+6+5+7 = **82** (JSON·공식 ko 원문 일치).
- 기존 학습문서 ↔ Task 매핑의 근거와 문서별 상세는 `98-existing-gap.md` 머리말의 매핑표 참조.
- Task 4.1~4.4의 첫 두 Knowledge(비용 관리 서비스 기능·도구)는 4개 Task가 **똑같이 반복**한다 → `tasks/4-1.md` §2-12·F-30~F-36에서 한 번 정리하고 4.2~4.4는 교차 참조.

---

## 4. 레포 `flutter_app/assets/exam_guides/SAA-C03.json` 대조

**방법**: JSON 문자열을 공식 ko 도메인 페이지 텍스트와 항목 단위로 직접 대조(도메인 1~3은 2026-10-19 재대조, 도메인 4는 2026-10-19 대조; 이전 단계의 Task별 대조 결과도 동일). **대조 대상 189개 항목 중 185개 일치, 4개 불일치**. 코드 실행·스크립트 없이 수행했다.

**`overview` 필드**: `level` Associate · `passingScore` 720 · `scoredQuestions` 50 · `unscoredQuestions` 15 · `durationMinutes` 130 — **전부 일치**(시간은 웹 가이드가 아닌 인증 페이지가 출처). 도메인 4개의 이름·`weightPct`(30/26/24/20), Task 14개의 번호·제목, `slug`·`sourceUrl`도 일치.

### 불일치 4건
| # | 위치 | JSON 문구 | 공식 ko 문구(2026-10-19) | 차이 유형 | 수정 제안 |
|---|---|---|---|---|---|
| 1 | Task **1.2** 지식 5번째 | "적절한 사용 사례를 갖춘 보안 서비스(예: **AWS Cognito, AWS GuardDuty, AWS Macie**)" | "보안 서비스와 적합한 사용 사례(예: **Amazon Cognito, Amazon GuardDuty, Amazon Macie**)" | 문구 + 서비스 접두어(AWS→Amazon) | 공식 문구로 교체 |
| 2 | Task **3.4** 지식 3번째 | "로드 밸런싱 개념(예: Application Load Balancer)" | "로드 밸런싱 개념(예: Application Load Balancer**(ALB)**)" | "(ALB)" 누락 | "(ALB)" 추가 |
| 3 | Task **3.5** 지식 1번째 | "…(예: Amazon Athena, AWS Lake Formation, Amazon **QuickSuite**)" | "…(예: Amazon Athena, AWS Lake Formation, Amazon **Quick**)" | 서비스 명칭 | "Amazon Quick"으로 교체 |
| 4 | Task **4.4** 지식 3번째 | "로드 밸런싱 개념(예: Application Load Balancer)" | "로드 밸런싱 개념(예: Application Load Balancer**(ALB)**)" | "(ALB)" 누락 | "(ALB)" 추가 |

> 같은 "로드 밸런싱 개념" 항목이 Task 2.1("…Application Load Balancer(ALB)")·2.2("…ALB")에는 공식 문구대로 들어 있다. 불일치 4건은 모두 *표기 수준*이며 항목의 의미나 개수는 달라지지 않았다. 구체적인 수정 문자열과 근거는 `99-gaps.md`의 "JSON 수정 제안" 참조.

**영문 원문에서 관찰한 비일관**(JSON과 무관): Task 2.1 지식은 "AWS managed services", Task 2.2 지식은 "AWS Managed Services (AMS) with appropriate use cases (for example, Amazon Comprehend, Amazon Polly)"로 표기가 다르고, 2.2의 예시가 AMS와 무관한 AI 서비스라 의미가 모호하다(`tasks/2-2.md`, `99-gaps.md`).

---

## 5. 공식 서비스 범위 목록(In-Scope / Out-of-Scope) 요약 (2026-10-19 열람)

공식 설명: 두 목록 모두 **"non-exhaustive and subject to change"**(비포괄·변경 가능). In-Scope에 없는 서비스가 곧 범위 밖은 아니다.

**In-Scope(카테고리 16개)**: Analytics(Athena·Data Exchange·Data Firehose·EMR·Glue·Kinesis·Lake Formation·MSK·OpenSearch Service·Amazon Quick·Redshift) · Application Integration(AppFlow·EventBridge·MQ·SNS·SQS·Step Functions) · **AWS Cost Management(Budgets·Cost and Usage Report·Cost Explorer·Savings Plans)** · Compute(Batch·EC2·EC2 Auto Scaling·Elastic Beanstalk·Outposts·Serverless Application Repository·VMware Cloud on AWS·Wavelength) · Containers(ECR·ECS·ECS Anywhere·EKS·EKS Anywhere·EKS Distro) · Database(Aurora·**Aurora Serverless**·DocumentDB·DynamoDB·ElastiCache·Keyspaces·Neptune·RDS·Redshift) · Developer Tools(X-Ray) · Front-End Web and Mobile(Amplify·API Gateway·Device Farm) · Machine Learning(Comprehend·Lex·Polly·Rekognition·SageMaker AI·Textract·Transcribe·Translate) · Management and Governance(Auto Scaling·CLI·CloudFormation·CloudTrail·CloudWatch·**Compute Optimizer**·Config·Control Tower·Health Dashboard·License Manager·Managed Grafana·Managed Service for Prometheus·Management Console·Organizations·Service Catalog·Systems Manager·**Trusted Advisor**·Well-Architected Tool) · Media Services(Elastic Transcoder·**Kinesis Video Streams**) · Migration and Transfer(Application Migration Service·DataSync·DMS·**Snow Family**·Transfer Family) · Networking and Content Delivery(Client VPN·CloudFront·Direct Connect·ELB·Global Accelerator·PrivateLink·Route 53·Site-to-Site VPN·Transit Gateway·VPC) · Security, Identity, and Compliance(Artifact·ACM·CloudHSM·Cognito·Detective·Directory Service·Firewall Manager·GuardDuty·IAM Identity Center·Inspector·KMS·Macie·Network Firewall·RAM·Secrets Manager·Security Hub·Shield·WAF·IAM) · Serverless(Fargate·Lambda) · Storage(AWS Backup·EBS·EFS·FSx(모든 유형)·S3·**S3 Glacier**·Storage Gateway).

**Out-of-Scope(예)**: Application Integration — Amazon MWAA · AR/VR — Sumerian · Blockchain — Managed Blockchain · Compute — **Lightsail** · Database — RDS on VMware · Developer Tools — **CDK·CloudShell·CodeArtifact·CodeBuild·CodeCommit·CodeDeploy·Corretto·Fault Injection Simulator·Tools and SDKs** · Front-End — Location Service · Game Tech — GameLift · **Internet of Things — 전 서비스** · Machine Learning — DeepComposer·DLAMI·Deep Learning Containers·**DevOps Guru**·Elastic Inference·HealthLake·Inferentia·Personalize 외 · Management and Governance — Console Mobile Application·Distro for OpenTelemetry · Media — Elemental 계열·IVS · Migration — Migration Evaluator · Networking — **AWS Cloud Map** · Quantum — Braket · Satellite — Ground Station.

**연구·대조에 영향을 준 관찰**
1. **Snow Family**는 In-Scope 목록에 여전히 있으나 실제 서비스는 신규 고객 불가(`tasks/3-5.md` F-09) — 목록만으로 "현행 선택지"를 단정하면 안 된다.
2. **Aurora Serverless**는 목록에 구 명칭으로 남아 있고 서비스는 2026-04에 "Aurora serverless"로 개명(`tasks/3-3.md` F-07).
3. **Kinesis Video Streams**는 In-Scope(Media Services)이므로 `saa-t3-9`의 해당 절은 "범위 밖 과잉"이 아니다(`98-existing-gap.md` G-3.5-19 정정).
4. **Amazon MWAA·AWS Cloud Map·Lightsail·Fault Injection Simulator·DevOps Guru·CloudShell·IoT 전 서비스**는 Out-of-Scope — 연구 파일 중 3.5의 MWAA 행에 이 점을 표기했다.
5. 연구 파일에서 다룬 일부 서비스는 **두 목록 어디에도 없다**: MemoryDB(`3-3.md` F-15)·Timestream(`3-3.md` F-19, `4-3.md` F-16)·App Runner(`3-2.md` F-16)·AWS Cloud WAN(`3-4.md` F-21)·AWS Elastic Disaster Recovery(`2-2.md`) 등. 목록이 비포괄이라 범위 여부는 단정하지 않으며, 시험 대비 우선순위 판단은 사람이 한다.
6. **비용 도구**(Budgets·Cost and Usage Report·Cost Explorer·Savings Plans)와 **Compute Optimizer·Trusted Advisor**가 In-Scope임 → Task 4.x의 도구 설명(`tasks/4-1.md` §2-12)이 시험 범위와 직결된다. **Cost Anomaly Detection·Cost Optimization Hub·Data Exports(CUR 2.0)** 는 목록에 명시되지 않음(기존 `saa-t4-5`가 Anomaly Detection을 다루는 것은 보조 서술).

---

## 6. 시험 대비에 영향을 주는 서비스 명칭·수명주기·요금 변화 (이번 조사에서 확인)

| 변화 | 핵심 내용 | 확인 위치 |
|---|---|---|
| Aurora Serverless v2 → "Aurora serverless" | 2026-04 개명, 플랫폼 v4(최대 30% 성능, 0 ACU 자동 일시정지 유지) | `3-3.md` F-07 |
| Aurora 스토리지 상한 | 256 TiB(PostgreSQL 17.5+·16.9+·15.13+, MySQL 3.10+), 그 이전 128 TiB | `3-3.md` F-03 |
| ElastiCache 엔진 | Valkey·Memcached·Redis OSS. Valkey는 Serverless 33%·노드 20% 저렴 | `3-3.md` F-11 · `4-3.md` F-13 |
| Timestream for LiveAnalytics | 2025-06-20부터 신규 고객 접근 종료(InfluxDB 검토 권고) | `3-3.md` F-19 · `4-3.md` F-16 |
| RDS Custom for Oracle | 2027-03-31 지원 종료 | `3-3.md` F-19 |
| Snow Family | 어떤 디바이스도 신규 주문 불가, Snowball Edge 유지보수 전환(2025-11-07). 대안 DataSync·Data Transfer Terminal | `3-5.md` F-09 |
| FSx File Gateway | 2024-10-28부터 신규 고객 불가 | `3-1.md` F-20 |
| 명칭 변경 | Kinesis Data Analytics→Managed Service for Apache Flink, Kinesis Data Firehose→Amazon Data Firehose, QuickSight→Amazon Quick | `3-5.md` F-05·머리말 |
| AWS App Runner | 2026-04-30부터 신규 고객 불가(유지보수) | `3-2.md` F-16 |
| EC2 시작 구성(launch configuration) | 2024-10-01부터 신규 계정 미지원(시작 템플릿 권장) | `3-2.md` F-12 |
| AWS 지원 플랜 | Developer·Business 2027-01-01 종료, Enterprise On-Ramp 종료, Business Support+ 신설 → Trusted Advisor 전체 점검 조건 영향 | `4-1.md` F-35 |
| **공용 IPv4 요금** | 2024-02-01부터 모든 공용 IPv4 $0.005/IP/시간(사용 중·유휴 모두) | `4-4.md` F-08 |
| **Savings Plans 유형** | 4종(Compute·EC2 Instance·**Database**[1년, re:Invent 2025]·SageMaker AI). "Savings Plans는 RDS에 적용되지 않는다"는 서술은 구식 | `4-2.md` F-02 · `4-3.md` F-06 |
| Regional NAT gateway | AZ 자동 확장형 NAT 추가(Private NAT 미지원) | `1-2.md` F-10 · `4-4.md` F-07 |
| CloudFront flat-rate 요금제 | Free/Pro/Business/Premium, 초과 요금 없음 | `4-4.md` F-17 |
| CUR 2.0 | Data Exports의 CUR 2.0이 신규·권장 방식(기존 CUR은 Legacy Pages) | `4-1.md` F-34 |
| S3 수명 주기 | 2024-09 이후 설정은 128 KB 미만 객체 기본 미전환 | `4-1.md` F-08 |
| RDS Extended Support | EOL 이후 메이저 버전 사용 시 vCPU-시간당 추가 과금 | `4-3.md` F-09 |
| Compute Optimizer 확대 | RDS·Aurora 권고와 유휴(NAT Gateway·DynamoDB·ElastiCache 등) 권고 | `4-2.md` F-13 |
| EBS gp3 한도 | 80,000 IOPS·2,000 MiB/s(옛 서술 16,000/1,000 주의) | `3-1.md` F-07 |
| Lambda Managed Instances | EC2 요금 모델을 쓰는 Lambda 실행 옵션 추가 | `2-1.md` F-16 · `4-2.md` F-15 |

---

## 7. 방법과 한계
- **도구**: AWS 공식 문서 검색·열람(MCP), 레거시 PDF 메타데이터 확인(WebFetch), 레포 파일 읽기, 집계용 읽기 전용 셸 유틸리티(grep·sed·awk·wc). git·flutter·npm·py 사용 없음, 쓰기는 이 폴더에만.
- **인용 규칙**: 영문 원문 15단어 이내 인용 + 한국어 의역, 3자 자료는 `[3자]` 표기(이번 연구에서는 사용하지 않음).
- **금액·수치**: 요금·할인율·한도는 리전·시점 예시이며, 시험은 *구조와 관계*를 묻는다고 보고 정리했다. 확인하지 못한 수치는 본문에 쓰지 않고 `99-gaps.md`에 남겼다.
- **알려진 한계**: ① 레거시 PDF 본문 재확인 불가(§2) ② 웹 가이드에 발행일 없음 ③ 일부 서비스의 현행 요금표(예: Regional NAT)는 열람하지 못함 ④ 영문 가이드와 ko 번역 간 의미 차이는 Task별 파일에서 별도 표기 ⑤ 같은 공식 페이지 안에서도 표와 본문의 수치·표기가 다른 경우가 있다(예: S3 Glacier 클래스 비교표 vs 본문 — `99-gaps.md` C-04). 그런 항목은 한쪽을 골라 단정하지 않고 양쪽을 병기했다.

---

## 8. 요약 수치 (2026-10-19 `grep` 실측)

**Task 커버: 14/14** — 1.1·1.2·1.3·2.1·2.2·3.1·3.2·3.3·3.4·3.5·4.1·4.2·4.3·4.4 (각 `tasks/<n-m>.md`). 공식 Knowledge 107 + Skills 82 = 189개 항목.

| Task | 고유 출처 URL | 사실표 F행 | Task | 고유 출처 URL | 사실표 F행 |
|---|---|---|---|---|---|
| 1.1 | 26 | 40 | 3.3 | 72 | 22 |
| 1.2 | 45 | 40 | 3.4 | 77 | 22 |
| 1.3 | 45 | 36 | 3.5 | 55 | 16 |
| 2.1 | 48 | 29 | 4.1 | 107 | 36 |
| 2.2 | 53 | 26 | 4.2 | 78 | 25 |
| 3.1 | 62 | 24 | 4.3 | 56 | 21 |
| 3.2 | 78 | 25 | 4.4 | 46 | 22 |

- **출처 URL**: Task별 합 848(Task 간 중복 포함), 14개 파일 통합 고유 787. 문서 안에 전체 URL로 적힌 것만 센 값이며, 같은 경로의 축약 표기(`…/slug`)는 세지 않았으므로 실제 근거 수는 이보다 많다. 도메인은 docs.aws.amazon.com · aws.amazon.com · repost.aws(knowledge-center, 그리고 4-2의 `[re:Post]` 글 1건) · d1.awsstatic.com(PDF 메타데이터 1건)뿐이며 `[3자]` 자료·시험 덤프 사이트는 0건.
- **레포 JSON 대조**: `SAA-C03.json` 189개 항목 중 불일치 **4건**(표기 수준, §4) — 수정 제안은 `99-gaps.md` §5.
- **`98-existing-gap.md`**: 총 303행, 문제 행 285(`[일치]` 8·`[과잉]` "없음" 10 제외), `[오류]` 6건(G-1.1-07·G-1.2-06·G-1.3-06·G-2.1-10·G-3.3-10·G-3.4-10).
- **`99-gaps.md`**: 열린 항목 **106건**(상충 21 + 확인 필요 80 + 전 문서 공통 이슈 5), 이번 단계에서 해소된 이전 미확보 8건, JSON 수정 제안 4건. 건수는 행 단위이며, 한 행이 여러 사실을 묶는 경우가 있다.
