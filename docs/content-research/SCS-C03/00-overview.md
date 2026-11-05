# SCS-C03 조사 개요 — 공식 가이드 전수 실측

> **측정일 2026-11-06 · 컨트롤러 직접 실측.** 모든 수치는 공식 가이드 페이지에서 기계 추출했고, 「없다」 판정은 **추출 둘 + 대조군**을 거쳤다. 이 문서가 SCS-C03 구조 수치의 정본이다.

## 1. 가이드 위치와 버전

| 항목 | 값 |
|---|---|
| 가이드 루트 | `docs.aws.amazon.com/aws-certification/latest/security-specialty-03/` |
| 한국어 | `docs.aws.amazon.com/ko_kr/aws-certification/latest/security-specialty-03/` — **전문 번역**(분량이 영문과 맞먹는다) |
| 가이드 버전 | **1.0 · 2026년 3월 26일 게시**(변경 기록이 이 한 줄뿐) |
| 시험 전환 | **SCS-C02는 2025년 12월 1일까지 · SCS-C03은 2025년 12월 2일부터**(부록 B) |
| `.md` 판 | 모든 페이지가 `.md`로도 제공된다 — **추출은 이쪽이 깨끗하다** |

⭐ **DVA식 전환 함정이 없다.** C03은 이미 약 1년간 현행이고, 실측하면 `security-specialty-02`와 무버전 `security-specialty` 슬러그는 **둘 다 404**다(대조군: 존재하지 않는 가이드 슬러그도 `404 r=0` — 이 가이드 계열은 없는 가이드에 진짜 404를 준다).

⚠️ **개정 표가 한 줄이라 AIF의 「개정 표 ↔ 본문 어긋남」 함정이 구조적으로 없다.** 다만 **개정 표는 번역 변경을 담지 않는다**(§4·97 §2 참고).

## 2. 시험 구조

| 항목 | 값 | 근거 |
|---|---|---|
| 등급 | Specialty | 인증 페이지 |
| 시간 | **170분** | ⚠️ **가이드 본문에 없다** — 인증 페이지가 근거다(AIF와 같은 상황) |
| 문항 | **채점 50 + 비채점 15 = 65** | 가이드 「시험 콘텐츠」 |
| 합격 | **750**(100~1,000 변환 점수) | 가이드 「시험 결과」 |
| 비용 | 300 USD | 인증 페이지 |
| 채점 모델 | **보상 점수 모델** — 섹션별 합격 불필요, 전체만 | 가이드 |
| 언어 | 영어·일본어·**한국어**·포르투갈어(BR)·간체 중국어·스페인어(LatAm) | 인증 페이지 |

⭐ **한국어는 은퇴 대상이 아니다.** 인증 페이지가 "간체 중국어·스페인어(LatAm)·포르투갈어(BR) 판은 **2026년 12월 31일 이후 은퇴**"라고 적는데 **한국어는 그 목록에 없다.** 이 레포가 한국어 콘텐츠를 만드는 전제가 유지된다.

### 답안 유형 4종 (AIF와 같은 제약)

**선다형**(정답 1 + 오답 3) · **복수 응답형**(5개 이상 중 2개 이상 정답) · **순서 배열**(3~5개를 올바른 순서로) · **매칭형**(3~7개 쌍 전부 정확해야 득점).

⚠️ **이 레포의 문항 스키마는 단일 정답 4지선다 하나다.** AIF 저작 결정 D-05와 같은 판정이 필요하다(98-authoring-decisions **D-03**).

## 3. 도메인·Task·기술

| 도메인 | 이름 | 비중 | Task | 기술 |
|---|---|---|---|---|
| 1 | 탐지 | 16% | 3 | 13 |
| 2 | 인시던트 대응 | 14% | 2 | 9 |
| 3 | 인프라 보안 | 18% | 3 | 16 |
| 4 | **ID 및 액세스 관리** | **20%** | 2 | 8 |
| 5 | 데이터 보호 | 18% | 3 | 12 |
| 6 | 보안 기반 및 거버넌스 | 14% | 3 | 12 |
| | | **100%** | **16** | **70** |

**Task 16개 (도메인 페이지 제목 — 이쪽이 정본이다)**

- D1: `1.1` AWS 계정 또는 조직용 모니터링 및 경보 솔루션 설계 및 구현 · `1.2` 로깅 솔루션 설계 및 구현 · `1.3` 보안 모니터링, 로깅 및 경보 솔루션 문제 해결
- D2: `2.1` 인시던트 대응 계획 설계 및 테스트 · `2.2` 보안 이벤트에 대응
- D3: `3.1` 네트워크 엣지 서비스의 보안 제어 설계, 구현 및 문제 해결 · `3.2` 컴퓨팅 워크로드에 대한 보안 제어 설계, 구현 및 문제 해결 · `3.3` 네트워크 보안 제어 설계 및 문제 해결
- D4: `4.1` 인증 전략 설계, 구현 및 문제 해결 · `4.2` 권한 부여 전략 설계, 구현 및 문제 해결
- D5: `5.1` 전송 중인 데이터에 대한 제어 설계 및 구현 · `5.2` 저장 데이터에 대한 제어 설계 및 구현 · `5.3` 기밀 데이터, ID, 보안 암호, 암호화 키 자료를 보호하기 위한 제어 기능 설계 및 구현
- D6: `6.1` AWS 계정을 중앙에서 배포하고 관리하기 위한 전략 개발 · `6.2` 클라우드 리소스를 안전하고 일관성 있게 배포할 수 있는 전략 구현 · `6.3` AWS 리소스의 규정 준수 평가

⭐ **SCS는 계층이 하나다** — Task 아래 **「관련 기술」**뿐이고 **번호가 공식 본문에 직접 적혀 있다**(`기술 2.1.1`). AIF는 번호를 유도해야 했지만(AIF G-04) **SCS는 그럴 필요가 없다.**

⚠️ **AIF와 층 이름이 반대다** — AIF JSON은 `knowledge`만, SCS JSON은 `skills`만 쓴다. 가드를 복제할 때 이 축을 확인한다.

## 4. 공식 내부 어긋남 (실측 — 99-gaps G-03이 정본)

1. ⚠️ **부록 B와 도메인 페이지가 Task 제목을 다르게 적는다.** 부록의 재분류 절은 `1.1 … 경보 **기능** 설계 및 구현` · `1.2 **로깅** 설계 및 구현` · `1.3 보안 모니터링, 로깅**,** 경보 **관련 문제 해결**`인데, 도메인 페이지는 `경보 **솔루션**` · `**로깅 솔루션**` · `로깅 **및** 경보 **솔루션 문제 해결**`이다. → **도메인 페이지를 정본으로** 쓴다(AIF D-06과 같은 규율).
2. ⚠️ **부록 B의 「삭제된 내용」은 C02 번호를, 「추가된 내용」은 C03 번호를 쓴다.** 「작업 6.4·2.5·3.4에서 제거」는 **C02** 기준이고 C03에는 그 번호가 없다(C03은 6.1~6.3 · 2.1~2.2 · 3.1~3.3). 섞어 읽으면 존재하지 않는 Task를 가리킨다.
3. ⚠️ **인증 페이지와 가이드가 대상 응시자 경력을 다르게 적는다.** 가이드는 **"클라우드 솔루션 보안 분야 3~5년"**, 인증 페이지는 **"5년의 IT 보안 경력 + 2년 이상의 AWS 워크로드 보안 실무"**다.
4. ⚠️ **한국어 표기 오류 1건** — `기술 6.2.4`가 `AWS Resource Access Manager(AWSRAM)`로 **공백을 빠뜨린다.** 같은 가이드의 범위 내 서비스 목록은 `AWS Resource Access Manager(AWS RAM)`로 **바르게** 적고 영문도 `[AWS RAM]`이다. → **`AWS RAM`을 쓴다.**
5. ⚠️ **범위 서비스 페이지 슬러그가 C02 시절 이름이다** — `scs-02-in-scope-services.html` · `scs-02-out-of-scope-services.html`. C03 가이드 안에서 `scs-02-` 접두사를 쓰므로 **슬러그를 보고 C02 문서라고 오판하면 안 된다.**

## 5. 한국어 ↔ 영문 대조 (AIF G-18·G-21의 교훈을 선제 적용)

- Task 번호 집합 **일치**(16/16) · 기술 번호 집합 **일치**(70/70) · 번호 누락 **0건**
- 기술 본문의 괄호 예시 블록 수 **차이 0건**
- 서비스 이름 차이로 보였던 **18건은 전부 정규식이 영문 산문을 오탐한 것**이었다(`AWS services and applications` 같은 구절). 실제 차이는 **0건**이다. ⚠️ **대조 스크립트의 오탐을 「차이」로 보고하지 않도록 후보마다 원문을 열어 확인했다.**
- 유일한 실질 차이는 위 §4-4의 **표기 오류**다.

⭐ **즉 SCS-C03 한국어 판은 영문과 내용이 같다.** AIF 목표 3.2.1처럼 한쪽에만 있는 개념(AIF G-18)은 **없다.**

## 6. 범위 내 AWS 서비스 — 10 범주 · 71개

| 범주 | 개수 | 서비스 |
|---|---|---|
| 분석 | 2 | Amazon Athena · Amazon OpenSearch Service |
| 애플리케이션 통합 | 2 | Amazon SNS · AWS Step Functions |
| 컴퓨팅 | 6 | Amazon API Gateway · Amazon EC2(EC2 Image Builder · EC2 Instance Connect) · Amazon EKS · Amazon EMR · AWS Lambda · Amazon Data Lifecycle Manager |
| 개발자 도구 | 1 | AWS Fault Injection Service |
| 사물 인터넷(IoT) | 1 | AWS IoT Core |
| 기계 학습 | 5 | Amazon Bedrock · **Amazon CodeGuru Security** · **Amazon Q Business** · **Amazon Q Developer** · Amazon SageMaker AI |
| AWS 관리 및 거버넌스 | 15 | AWS CloudFormation · AWS CloudTrail · AWS CloudTrail Lake · Amazon CloudWatch · AWS Config · AWS Control Tower · Amazon Managed Grafana · AWS Organizations · AWS Resilience Hub · AWS Resource Access Manager(AWS RAM) · AWS Service Catalog · AWS Systems Manager · AWS Trusted Advisor · AWS User Notifications · AWS Well-Architected Tool |
| 네트워킹 및 콘텐츠 전송 | 10 | Amazon Application Recovery Controller · Amazon VPC · AWS Client VPN · Amazon CloudFront · **Amazon Verified Permissions** · Amazon Route 53(Route 53 Resolver DNS Firewall) · AWS Direct Connect · Elastic Load Balancing(ELB) · Network Access Analyzer · AWS Transit Gateway |
| 보안, ID 및 규정 준수 | 24 | AWS Artifact · **AWS Audit Manager** · AWS Certificate Manager(ACM) · AWS CloudHSM · Amazon Cognito · Amazon Detective · AWS Directory Service · AWS Firewall Manager · Amazon EC2용 자동 포렌식 오케스트레이터 · Amazon GuardDuty · IAM · AWS IAM Identity Center · Amazon Inspector · AWS KMS · Amazon Macie · AWS Network Firewall · AWS Private Certificate Authority · AWS Secrets Manager · AWS Security Hub · Amazon Security Lake · AWS Shield · AWS Shield Advanced · AWS STS · AWS WAF |
| 스토리지 및 데이터 관리 | 5 | Amazon S3 · AWS Backup · AWS DataSync · Amazon EFS(EFS 수명 주기 정책) · Amazon FSx for Lustre |

⚠️⚠️ **굵게 표시한 넷 중 셋은 신규 고객에게 닫혔거나 지원이 종료됐다** — 99-gaps **G-02**가 정본이다.
⚠️ **`Amazon Verified Permissions`가 「네트워킹 및 콘텐츠 전송」에 들어 있다**(공식 분류 그대로). 서비스를 범주로 찾으면 못 찾는다.
⚠️ **`AWS PrivateLink`는 목록에 0건**이다(실측). 다만 목록이 "전체 목록이 아니며 변경될 수 있다"고 적고 `Amazon VPC`가 범위 내이므로 **「목록에 없다」 ≠ 「범위 밖」**이다(AIF G-10 규율).

## 7. 범위 외 AWS 서비스 — **단 2개**

**Amazon MWAA**(애플리케이션 통합) · **AWS Payment Cryptography**(보안·ID·규정 준수).

⭐ **AIF와 정반대다.** AIF는 범위 외 목록이 길어 「반사적으로 떠오르는데 쓸 수 없는 서비스」가 많았는데, SCS는 보안 전문 자격증이라 거의 전부가 범위 내다. **대신 상태가 닫힌 서비스가 범위 「내」에 있다**(§6).

## 8. 기술 및 개념 — 6개

AWS CLI · AWS SDK · AWS Management Console · 보안 원격 액세스 · 인증서 관리 · **코드형 인프라(IaC)**

## 9. 대상 응시자 범위 밖 작업 (출제되지 않는 축)

암호화 알고리즘 **설계** · **패킷 수준** 트래픽 분석 · 전체 클라우드 배포 **아키텍팅** · 최종 사용자 컴퓨팅 리소스 관리 · **기계 학습 모델 훈련**

⚠️ 마지막 항목이 중요하다 — **범위 내에 `Amazon Bedrock`·`Amazon SageMaker AI`가 있지만 「모델 훈련」은 출제 축이 아니다.** 생성형 AI는 **보호·가드레일 쪽**으로만 들어온다(C03 신규 `기술 3.2.7`).

## 10. C02 → C03 변경 (부록 B)

### 도메인 재편
- C02의 **「위협 탐지 및 인시던트 대응」(14%)** + **「보안 로깅 및 모니터링」(18%)** → C03의 **「탐지」(16%)** + **「인시던트 대응」(14%)**
- C02 D6 **「관리 및 보안 거버넌스」** → C03 **「보안 기반 및 거버넌스」**(이름 변경)
- 비중 이동: 인프라 보안 20 → **18** · ID 및 액세스 관리 16 → **20**

### C03에 추가된 기술 7건 (저작 우선순위가 높다)

| 번호 | 내용 |
|---|---|
| `2.2.3` | AWS 보안 서비스의 조사 결과를 확인하여 이벤트의 범위와 영향 평가 |
| `3.1.4` | AWS 엣지 서비스 및 타사 서비스와의 통합 구성(**OCSF 형식** 데이터 수집, 타사 WAF 규칙) |
| **`3.2.7`** | **생성형 AI 애플리케이션용 보호 및 가드레일 구현**(LLM 애플리케이션 보호용 **GenAI OWASP 상위 10개**) |
| `5.1.3` | 전송 중인 리소스 간 암호화 설계·구성(**Amazon EMR · EKS · SageMaker AI 노드 간 암호화 · Nitro 암호화**) |
| `5.3.3` | **가져온 키 자료와 AWS에서 생성한 키 자료의 차이** |
| `5.3.4` | **민감한 데이터 마스킹**(**CloudWatch Logs 데이터 보호 정책** · **SNS 메시지 데이터 보호**) |
| `5.3.5` | 단일·다중 리전에서 암호화 키와 인증서 생성·관리(KMS 고객 관리형 키 · AWS Private CA) |

⭐ **`기술 5.3.4`가 AIF 트랙의 발견과 직접 이어진다** — AIF G-23이 "Guardrails의 PII 마스킹은 **로그에 적용되지 않고**(CloudWatch Logs의 `input`은 항상 원본) 대책은 **CloudWatch Logs 데이터 보호 정책**이며 **소급 적용되지 않는다"를 실측해 뒀다. 그 사실이 SCS에서는 **출제 축 자체**다.
⭐ **`기술 3.2.7`도 AIF와 겹친다** — Bedrock Guardrails의 정책 카탈로그·안전 조치 계층·한계는 `aif-t4-1`·`aif-t5-1`에 이미 실측돼 있다(AIF G-23). **재사용 후보 1순위다.**

### C03에서 삭제된 내용 (C02 번호 기준)

작업 6.4 아키텍처 검토·비용 분석 허점 식별 · 작업 1.1 **ASFF** · 작업 1.3 AWS 보안 인시던트 대응 가이드 · 작업 2.5 로그 형식·구성 요소 · 작업 3.3 **호스트 기반 보안**(방화벽·강화) · 작업 3.4 **VPC Reachability Analyzer** 연결성 분석·**기본 TCP/IP 개념**(UDP/TCP·포트·OSI) · 작업 4.2 **정책의 구성 요소**(보안 주체·작업·리소스·조건) · 작업 5.1 **TLS 개념**·프라이빗/퍼블릭 VIF 크로스 리전 · 작업 5.2 S3 정적 웹 사이트 호스팅

⚠️ **삭제됐다고 「몰라도 된다」가 아니다** — 정책 구성 요소나 TLS 개념은 다른 기술을 이해하는 전제다. **다만 그것을 「묻는」 문항은 만들지 않는다.**
