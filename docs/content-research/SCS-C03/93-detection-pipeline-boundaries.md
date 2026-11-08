---
생성: 2026-11-08
목적: SCS-C03 「무엇이 무엇을 탐지하는가」의 서비스 경계와 신규 기술 3.1.4(OCSF·타사 WAF 규칙)의 공식 근거 수집
대상 기술: 1.1.4 · 1.1.5 · 1.2.3 · 1.2.4 · 2.2.3 · 2.2.5 · 3.1.4 · 3.2.3 · 6.3.1
조회일: 2026-11-08 (명시가 없는 모든 인용의 조회일이다)
---

# 93 — 탐지 파이프라인의 서비스 경계 (SCS-C03)

## 1. 왜 이 노트가 필요한가

공식 가이드는 탐지 서비스를 **예시 묶음**으로만 나열한다. `기술 1.1.4`가 "지표, 알림 및 대시보드를 사용하여 이상 동작 식별 및 이벤트 탐지(예: Amazon GuardDuty, Amazon Security Lake, AWS Security Hub, Amazon Macie)"로 네 개를 한 줄에 묶고, `기술 1.2.4`는 "로그 분석(예: CloudWatch Logs Insights, Amazon Athena, Security Hub 조사 결과)", `기술 2.2.5`는 "근본 원인 분석을 지원하는 기능 구성(예: Amazon Detective)", `기술 3.2.3`은 "컴퓨팅 리소스를 스캔하여 알려진 취약성 찾기(예: Amazon Inspector … GuardDuty … 런타임 모니터링)"로 적는다.

⚠️ **묶음 나열은 출제 각도를 숨긴다.** 이 서비스들은 역할이 겹쳐 보이지만 **각자 보는 입력이 다르고, 내놓는 산출물의 형식과 수명도 다르다.** 「S3에 민감 데이터가 있는지」는 Macie이고 「S3에서 데이터가 빠져나가는 중인지」는 GuardDuty이며 「그 두 신호가 한 리소스에서 겹쳐 실제 위험이 되는지」는 신 Security Hub다. 어느 서비스를 켜야 그 사실을 알 수 있는지가 갈림길이고, 그 갈림길은 묶음 나열에 적혀 있지 않다.

게다가 C03은 **`기술 3.1.4`를 신설**해 "AWS 엣지 서비스 및 타사 서비스와의 통합 구성(예: 오픈 사이버 보안 스키마 프레임워크(OCSF) 형식으로 데이터 수집, 타사 WAF 규칙 통합)"을 요구한다. OCSF가 가이드에 처음 등장했는데 **OCSF를 쓰는 AWS 서비스가 둘**이고(§4) 둘의 **지원 버전이 서로 다르다**(§4-3). 이 노트는 그 경계를 공식 문서 실측으로 고정한다.

## 2. ⚠️⚠️ 이 노트에서 가장 중요한 실측 — Security Hub가 둘로 갈렸다

**공식 문서의 what-is 페이지 제목이 「Introduction to AWS Security Hub CSPM」이다.** 가이드가 적는 이름은 「AWS Security Hub」인데, 그 이름은 지금 **다른 제품**을 가리킨다.

| | **AWS Security Hub CSPM** | **AWS Security Hub** (신) |
| --- | --- | --- |
| 옛 이름 | 그냥 `Security Hub`였던 것 | — (신규) |
| 하는 일 | 보안 표준 대조 + 통합 서비스 조사 결과 집계 | **노출 조사 결과**(exposure findings) 생성 — 신호를 **상관**해 공격 경로를 드러낸다 |
| 조사 결과 형식 | **ASFF**(AWS Security Finding Format) | **OCSF**(현재 **스키마 1.6**) |
| 조사 결과 출처 | AWS Config · AWS WAF · GuardDuty · Inspector · 타사 파트너 도구 · 사용자 정의 | **Security Hub CSPM · GuardDuty · Inspector · Macie** |
| EventBridge `detail-type` | `Security Hub Findings – Imported` | `Findings Imported V2` |

출처: [Introduction to AWS Security Hub CSPM](https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html) · [Exposure findings in Security Hub](https://docs.aws.amazon.com/securityhub/latest/userguide/exposure-findings.html) · [Security Hub and the Open Cybersecurity Schema Framework (OCSF)](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-ocsf.html) · [AWS Security Hub FAQ](https://aws.amazon.com/security-hub/faqs/)

FAQ가 둘의 차이를 **네 축**(출처·유형·형식·이벤트 전달)으로 직접 정리해 둔다. 이 표의 마지막 두 행은 그 FAQ에서 왔다.

⚠️ **구조 자체가 어긋나 있다.** 두 제품이 **같은 사용자 안내서**(`securityhub/latest/userguide/`)를 쓰는데, 그 안내서의 what-is 슬롯은 **CSPM이 차지하고 있다.** 신 Security Hub 쪽 what-is 슬러그를 추측해 재면(`what-is-security-hub.html`, 하이픈) **죽은 슬러그**다(§8). 그래서 신 Security Hub를 가리킬 때는 **개념 페이지**(`exposure-findings.html`·`securityhub-ocsf.html`)를 인용한다.

⚠️ **저작 규율:** 레포 콘텐츠에서 「Security Hub」라고만 쓰면 학습자가 어느 쪽인지 모른다. **표준 점검·ASFF·AWS Config 의존을 말할 때는 `Security Hub CSPM`**, **노출 조사 결과·OCSF·상관을 말할 때는 `Security Hub`**로 적는다. 공식 가이드 JSON은 전사이므로 손대지 않는다(D-05와 같은 층 구분).

## 3. 서비스별 사실

### 3.1 Amazon GuardDuty — 「지금 무슨 일이 벌어지는가」

출처: [What is Amazon GuardDuty?](https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html)

**기초 데이터 소스는 켤 것이 없다.** 계정에서 GuardDuty를 켜면 **CloudTrail 관리 이벤트 · VPC 흐름 로그(EC2 인스턴스) · DNS 로그**를 자동으로 수집한다("You don't need to enable anything else").

**Extended Threat Detection** — 개별로는 위협으로 보이지 않는 이벤트들이 의심스러운 **순서**로 관측되면 **공격 시퀀스**(attack sequence)로 식별한다. ⚠️ **추가 비용이 없고 계정마다 자동으로 켜진다**("With no additional cost associated with it, Extended Threat Detection is automatically enabled for each AWS account when they enable GuardDuty"). 보호 플랜을 켤 필요도 없다 — 다만 S3 리소스까지 넓히려면 S3 Protection을 권한다.

**보호 플랜 9종** (선택형): AI Protection(Bedrock·Bedrock AgentCore·SageMaker AI) · S3 Protection · EKS Protection · Runtime Monitoring · Malware Protection for EC2 · Malware Protection for S3 · Malware Protection for AWS Backup · RDS Protection · Lambda Protection.

⚠️ **처음 켜면 Runtime Monitoring을 제외한 전 보호 플랜이 자동으로 켜지고 30일 무료 평가에 든다.** 반대로 **기존 고객**은 나중에 출시된 플랜이 자동으로 켜지지 않는다.
⚠️ **Malware Protection for S3는 GuardDuty 서비스를 켜지 않고 단독으로 쓸 수 있다**("without enabling the Amazon GuardDuty service"). 다른 플랜은 전부 GuardDuty를 켜야 한다. 「GuardDuty를 켜지 않고 S3 업로드 악성코드를 스캔할 수 있는가」는 **예**다.

그 밖에 **Custom Detection Rules**(위협 행위자 기법에 맞춘 큐레이션 규칙 — CloudTrail 관리 이벤트나 Runtime Monitoring 이벤트의 필드를 평가)와 **Investigation (Preview)**(MITRE ATT&CK® 분류·위험 평가를 포함한 조사 요약)이 있다.

### 3.2 Amazon Inspector — 「무엇이 취약한가」

출처: [What is Amazon Inspector?](https://docs.aws.amazon.com/inspector/latest/user/what-is-inspector.html)

취약성 관리 서비스로 **워크로드를 자동 발견**해 소프트웨어 취약성과 **의도하지 않은 네트워크 노출**을 계속 스캔한다. 대상은 **EC2 인스턴스 · ECR의 컨테이너 이미지 · Lambda 함수**다.

⚠️ **일정을 짜거나 스캔을 구성하지 않는다** — 적격 리소스를 자동 발견해 스캔을 시작하고, 새 패키지 설치·패치 설치·해당 리소스에 영향을 주는 **새 CVE 공개** 같은 변화에 **자동 재스캔**한다. 적절히 조치하면 **조사 결과를 자동으로 닫는다.**
⚠️ **Inspector 위험 점수는 NVD 기본 점수를 환경에 맞게 조정한 값**이다 — 공식 예시가 "네트워크로 악용 가능하지만 그 인스턴스에서 인터넷으로 열린 네트워크 경로가 없으면 점수를 **낮출 수 있다**"고 적는다. CVSS 형식이지만 **NVD 기본 점수와 같은 값이 아니다.**
⚠️ 조사 결과는 **EventBridge에 항상 게시**되고, **Security Hub CSPM을 활성화한 경우에만** 거기에도 게시된다.

### 3.3 Amazon Macie — 「민감 데이터가 어디 있는가」

출처: [What is Amazon Macie?](https://docs.aws.amazon.com/macie/latest/user/what-is-macie.html)

데이터 보안 서비스로 ML과 패턴 매칭으로 민감 데이터를 찾는다. 대상은 **Amazon S3**이고, 켜면 **S3 범용 버킷**(general purpose buckets) 인벤토리를 자동으로 만들어 보안·액세스 제어를 평가·모니터링한다.

**조사 결과가 두 종류다.** 버킷이 공개로 바뀌는 등 보안·프라이버시 문제는 **정책 조사 결과**(policy finding), 객체에서 민감 데이터를 찾으면 **민감 데이터 조사 결과**(sensitive data finding)다.

**검색 경로가 둘이다.** **자동 민감 데이터 검색**은 버킷 인벤토리를 계속 평가하며 **표본 추출**로 대표 객체를 골라 분석한다(폭넓은 가시성). **민감 데이터 검색 작업**은 분석할 버킷·표본 깊이·사용자 정의 기준을 직접 정하는 **더 깊고 표적화된 분석**이고 **1회성 또는 반복 실행**을 고를 수 있다.

**탐지 기준 3층**: **관리형 데이터 식별자**(여러 국가·지역의 PII·금융 정보·자격 증명 데이터) · **사용자 정의 데이터 식별자**(정규식 + 선택적 문자 시퀀스·근접 규칙) · **허용 목록**(무시할 텍스트·패턴).

### 3.4 Amazon Detective — 「왜 그렇게 됐는가」

출처: [What is Amazon Detective?](https://docs.aws.amazon.com/detective/latest/userguide/what-is-detective.html)

조사 결과나 의심스러운 활동의 **근본 원인**을 분석·식별한다. 로그를 자동 수집해 ML·통계 분석·**그래프 이론**으로 시각화를 만든다.

⚠️ **최대 1년의 과거 이벤트 데이터**에 접근할 수 있고, 변화를 **GuardDuty 조사 결과에 연결**한다. 즉 Detective는 **탐지하지 않는다** — 다른 서비스가 탐지한 것의 맥락을 만든다.
⚠️ **Security Lake 통합의 범위가 좁다.** 공식이 "Security Lake가 기본 지원하는 다음 소스"로 **CloudTrail 관리 이벤트 1.0 이상 · VPC 흐름 로그 1.0 이상 · EKS 감사 로그 2.0** 셋을 들지만, 통합 후 Detective가 실제로 당겨오는 원시 로그는 **"CloudTrail 관리 이벤트와 VPC 흐름 로그 관련"**이라고 적는다. **셋을 다 당겨온다고 단정하지 않는다.**

기능은 **조사 결과 그룹**(finding groups — 고심각도 GuardDuty 조사 결과의 근본 원인 분석, 행동 그래프에서 추출, 상호작용 시각화), **Detective Investigation**(IAM 사용자·역할을 **침해 지표**(IOC)로 조사 — `StartInvestigation` API), **VPC 흐름 볼륨 조사**(EC2 인스턴스별 집계, Kubernetes 파드는 할당 IP의 전체 바이트 볼륨)다.

### 3.5 Amazon Security Lake — 「전부 한곳에 모아 둔다」

출처: [What is Amazon Security Lake?](https://docs.aws.amazon.com/security-lake/latest/userguide/what-is-security-lake.html)

완전관리형 **보안 데이터 레이크**다. 데이터 레이크는 **내 계정의 S3 버킷**으로 뒷받침되고 **데이터 소유권은 내게 남는다.** 수집한 데이터를 **Apache Parquet** 형식과 **OCSF** 스키마로 변환한다.

**기본 지원 AWS 소스 6종** ([Collecting data from AWS services in Security Lake](https://docs.aws.amazon.com/security-lake/latest/userguide/internal-sources.html)):
CloudTrail **관리 및 데이터 이벤트(S3, Lambda)** · EKS 감사 로그 · **Route 53 Resolver 쿼리 로그** · **Security Hub CSPM 조사 결과** · VPC 흐름 로그 · **WAFv2 로그**.

⚠️ **그 서비스들에서 로깅을 따로 구성할 필요가 없다 — `CloudTrail 관리 이벤트`만 예외다.** 이미 로깅을 구성해 뒀어도 바꿀 필요가 없고, Security Lake는 **"독립적이고 중복된 이벤트 스트림"**으로 직접 당겨온다.
⚠️ **롤업 리전**(rollup Regions)으로 여러 리전의 데이터를 통합해 데이터 레지던시 요건에 맞춘다.
⚠️ 구독자(subscriber)는 **지정한 소스와 리전에서만** 데이터를 소비하고, 새 객체 알림을 받거나 쿼리하는 두 방식이 있다. 뒤에서 **EventBridge**(구독자 알림) · **AWS Glue**(크롤러·Data Catalog) · **Lake Formation**(소스별 테이블) · **Lambda**를 쓴다.

## 4. 신규 `기술 3.1.4` ① — OCSF

### 4-1. OCSF란

[Security Hub and the OCSF](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-ocsf.html)가 적는다: 확장 가능한 스키마 개발 프레임워크 + **벤더 중립 코어 보안 스키마**를 제공하는 오픈 소스 프로젝트이고, **데이터 타입·속성 사전·분류 체계**로 이뤄진다. **저장 형식·수집 방법·ETL 프로세스와 독립적**이다.

### 4-2. OCSF를 쓰는 AWS 서비스는 둘이고 역할이 다르다

| | **Amazon Security Lake** | **AWS Security Hub**(신) |
| --- | --- | --- |
| OCSF를 어디에 쓰나 | **로그·이벤트**를 OCSF + Parquet로 정규화해 데이터 레이크에 적재 | **조사 결과**의 표현 형식 |
| 산출물 | 쿼리 가능한 S3 데이터 레이크(Glue·Lake Formation 테이블) | 노출 조사 결과 |
| 왜 쓰나 | 이질적 스키마를 한 언어로 — 여러 보안 솔루션이 **병렬로** 소비 | 상관·분석과 도구 연계 |

### 4-3. ⚠️⚠️ 지원하는 OCSF 버전이 서로 다르다

- **Security Hub**: "Security Hub currently supports findings in **OCSF schema version 1.6**"
- **Security Lake 사용자 지정 소스**: "For custom sources, Security Lake supports **OCSF version 1.3 and earlier**"

**두 서비스가 같은 OCSF를 같은 수준으로 지원한다고 쓰면 거짓이 된다.** 다만 ⚠️ **버전 숫자를 묻는 문항은 만들지 않는다** — 올라가는 값이고 Specialty 시험의 축이 아니다. 축은 **「OCSF는 한 서비스의 형식이 아니라 두 서비스가 서로 다른 층에서 쓰는 공통 언어다」**다.

### 4-4. 타사 데이터를 OCSF로 받는 경로 — Security Lake 사용자 지정 소스

출처: [Collecting data from custom sources in Security Lake](https://docs.aws.amazon.com/security-lake/latest/userguide/custom-sources.html)

**사용자 지정 소스는 보내기 전에 로그·이벤트를 OCSF로 변환해야 한다.** Security Lake가 대신 변환해 주지 않는다(기본 지원 AWS 소스만 자동 변환이다). 요건은 다음과 같다.

- **대상**: 소스에 할당된 접두사 아래 S3 객체로 쓴다. 데이터 범주가 여럿이면 **고유 OCSF 이벤트 클래스마다 별도 소스**로 보낸다.
- **형식**: 각 S3 객체는 **Apache Parquet** 파일(Parquet 1.x·2.x 지원, 데이터 페이지 1 MB 이하(비압축), 행 그룹 256 MB 이하(압축), 압축은 **zstandard 권장**).
- **스키마**: 한 객체 안의 모든 레코드에 **같은 OCSF 이벤트 클래스**가 적용돼야 한다.
- **파티셔닝**: `source location/region=…/accountId=…/eventDay=yyyyMMdd/`. ⚠️ **AWS 밖 계정의 레코드는 `external` 또는 `external_externalAccountId` 같은 문자열을 권한다**(AWS 계정 ID와 충돌하지 않게).
- **객체 크기·주기**: **5분 ~ 1 이벤트 일** 사이로 보낸다(256 MB보다 크면 더 자주 보내도 된다).
- **정렬**: 객체 안에서 **시간순**으로 정렬하면 쿼리 비용이 줄어든다.

Security Lake가 대신 해 주는 것: 고유 접두사 제공 · 쓰기 권한 IAM 역할 생성(**권한 경계는 AWS 관리형 정책 `AmazonSecurityLakePermissionsBoundary`**) · Lake Formation 테이블 생성 · Glue 크롤러 설정.

⚠️ **계정당 사용자 지정 로그 소스는 최대 50개**다.
⚠️ 역할 이름 형식은 `AmazonSecurityLake-Provider-{소스 이름}-{리전}`이고, 데이터 레이크를 고객 관리형 KMS 키로 암호화했으면 `kms:Decrypt`·`kms:GenerateDataKey` 정책이 함께 붙는다.
⚠️ 호환성은 **OCSF Validation 도구**로 확인한다.

## 5. 신규 `기술 3.1.4` ② — 타사 WAF 규칙

출처: [Using managed rule groups in AWS WAF](https://docs.aws.amazon.com/waf/latest/developerguide/waf-managed-rule-groups.html) · [AWS Marketplace rule groups](https://docs.aws.amazon.com/waf/latest/developerguide/marketplace-rule-groups.html)

관리형 규칙 그룹은 **AWS와 AWS Marketplace 판매자**가 작성·유지하는 미리 정의된 규칙 묶음이다.

**과금 구분 3층** — ⚠️ 이것이 갈림길이다.
1. **Bot Control · Fraud Control ATP(계정 탈취 방지) · Fraud Control ACFP(계정 생성 사기 방지)** 세 AWS 관리형 규칙 그룹은 **기본 AWS WAF 요금 외에 추가 요금**이 있다.
2. **그 밖의 모든 AWS Managed Rules 규칙 그룹은 추가 비용 없이** 쓸 수 있다.
3. **AWS Marketplace 규칙 그룹은 구독**이고 판매자가 소유·관리한다. 요금은 판매자에게 문의한다.

**Marketplace 쪽 비자명한 사실 4종:**
- ⚠️⚠️ **Firewall Manager의 AWS WAF 정책에서 Marketplace 규칙 그룹을 쓰려면 조직의 **각 계정이 각각 구독**해야 한다.** 중앙에서 한 번 구독해 밀어 넣을 수 없다 — `기술 6.2.3`(Firewall Manager)과 `기술 3.1.4`가 만나는 자리다.
- ⚠️ 구독할 수 있는 유형이 **둘**이다: **AWS WAF 파트너 관리형 규칙 그룹**과 **클라이언트 측 보호**(client-side protections).
- ⚠️ 구독료는 월 단위(시간 비례)이고 **web ACL에 추가해 쓰기 시작할 때만** 부과된다.
- ⚠️ 버전 관리 여부·규칙·규칙 작업·레이블을 정하는 주체는 **판매자**다.

**규칙 그룹 내부는 볼 수 없다** — 제공자의 지식재산 보호와 악용 방지를 위해 개별 규칙의 모든 세부를 볼 수 없다. 그래서 **테스트 수단이 `Count` 작업**이다(규칙을 차단으로 바꾸기 전에 매칭 수를 센다).

⚠️ **GovCloud(US)에서는 Marketplace 타사 관리형 규칙 그룹을 쓸 수 없다** — AWS 관리형 규칙 그룹만 쓸 수 있다([AWS WAF in AWS GovCloud (US)](https://docs.aws.amazon.com/govcloud-us/latest/UserGuide/govcloud-waf.html)).

### 5-1. 함께 측정된 것 — WAF가 보호하는 리소스 유형 9종

[What are AWS WAF, AWS Shield Advanced, AWS Shield network security director and AWS Firewall Manager?](https://docs.aws.amazon.com/waf/latest/developerguide/what-is-aws-waf.html)가 적는 보호 대상: **CloudFront 배포 · API Gateway REST API · Application Load Balancer · AppSync GraphQL API · Cognito 사용자 풀 · App Runner 서비스 · Amazon Bedrock AgentCore Gateway · AWS Verified Access 인스턴스 · AWS Amplify**.

⚠️ **`Amazon Bedrock AgentCore Gateway`와 `AWS Amplify`가 목록에 있다** — 생성형 AI 애플리케이션 보호(신규 `기술 3.2.7`)와 이어진다.
⚠️ 같은 페이지가 **`AWS Shield network security director`**를 Shield Advanced와 **별도 제품**으로 소개한다. 가이드는 `Shield Advanced`만 적으므로(`기술 2.1.2`·`3.1.2`) **둘을 섞지 않는다.**
⚠️ WAF의 기본 동작은 **넷**이다: 지정한 것만 차단 / 지정한 것만 허용 / **Count** / **CAPTCHA·사일런트 챌린지**.

## 6. 경계 표 — 「무엇이 무엇을 보는가」

이 표가 이 노트의 결론이다. 저작 시 문항의 갈림길은 거의 전부 이 표의 한 칸이다.

| 서비스 | 입력(무엇을 보나) | 산출물 | 경계 — 이것은 하지 않는다 |
| --- | --- | --- | --- |
| **GuardDuty** | CloudTrail 관리 이벤트 · VPC 흐름 로그 · DNS 로그(기초, 자동) + 보호 플랜별 소스 | 위협 조사 결과 · **공격 시퀀스** | 취약성을 스캔하지 않는다 · 민감 데이터를 분류하지 않는다 · 구성 준수를 점검하지 않는다 |
| **Inspector** | EC2 · ECR 컨테이너 이미지 · Lambda 함수 | 취약성·네트워크 노출 조사 결과(환경 조정 위험 점수) | 런타임 행위를 보지 않는다(그쪽은 GuardDuty Runtime Monitoring) |
| **Macie** | S3 **범용 버킷**의 객체·버킷 설정 | 민감 데이터 조사 결과 · 정책 조사 결과 | S3 밖을 보지 않는다 · 위협 행위를 탐지하지 않는다 |
| **Security Hub CSPM** | AWS Config 등 통합 서비스 + 타사 + 사용자 정의 | **ASFF** 제어 조사 결과 · 보안 점수 | 상관으로 공격 경로를 만들지 않는다(그쪽은 신 Security Hub) |
| **Security Hub**(신) | Security Hub CSPM · Inspector · GuardDuty · Macie 신호 | **OCSF** **노출 조사 결과**(특성·신호·공격 경로·폭발 반경) | 자신이 탐지하지 않는다 — 상관한다 |
| **Detective** | 자동 수집 로그(최대 **1년** 과거) + GuardDuty 조사 결과 연결 | 행동 그래프 · 조사 결과 그룹 · 조사 | **탐지하지 않는다** — 근본 원인 맥락을 만든다 |
| **Security Lake** | 기본 지원 AWS 소스 6종 + 사용자 지정 소스(OCSF 변환은 소스 책임) | **OCSF + Parquet** 데이터 레이크(내 계정 S3) | 탐지도 상관도 하지 않는다 — 모으고 정규화한다 |

**비용·활성화 축의 비자명한 사실 셋** (문항의 두 번째 갈림길이다):
- **Security Hub CSPM은 소급 적용되지 않는다** — "only detects and consolidates findings that are generated **after** you enable"이고, **활성화한 리전에서만** 조사 결과를 받아 처리한다. CIS 벤치마크 전체 준수를 위해서는 **지원되는 모든 리전에서 켜야** 한다.
- **Security Hub CSPM의 대부분 제어는 AWS Config를 요구한다** — 서비스 연결 규칙을 쓰므로 **AWS Config를 켜고 리소스를 기록**해야 대부분의 제어 조사 결과가 생성된다. 다만 **보안 표준이 활성화한 AWS Config 규칙 자체에는 과금되지 않는다**(무료 평가 중 AWS Config 항목에는 과금된다).
- **GuardDuty Extended Threat Detection은 공짜이고 자동이다**(§3.1).

## 7. 출제 각도 (저작 시 참고)

1. **「이 사실을 알려면 무엇을 켜야 하나」** — 민감 데이터 위치(Macie) / 유출 시도(GuardDuty S3 Protection) / 둘이 겹친 실제 위험(신 Security Hub 노출 조사 결과).
2. **형식이 갈림길인 문항** — ASFF를 요구하는 기존 자동화가 있는데 신 Security Hub 조사 결과를 받으려면? → 형식(ASFF vs OCSF)과 EventBridge `detail-type`(`Security Hub Findings – Imported` vs `Findings Imported V2`)이 다르다.
3. **타사 로그를 데이터 레이크에 넣는 비용 최소 경로** — 사용자 지정 소스 요건(OCSF 변환은 **소스 책임** · Parquet · 파티셔닝 · 5분~1일)을 아는지.
4. **중앙 관리 함정** — Firewall Manager WAF 정책 + Marketplace 규칙 그룹 → **계정마다 구독**.
5. **「탐지했다」와 「조사한다」의 분리** — Detective는 탐지하지 않는다. GuardDuty 조사 결과 없이 Detective만 켜는 설계는 근본 원인 연결을 잃는다.
6. **소급 함정** — 사고가 난 **뒤에** Security Hub CSPM을 켜면 그 전 조사 결과는 집계되지 않는다.

## 8. ⚠️ 측정 기록 — 죽은 슬러그 5건과 대조군

전 인용 URL을 `curl -sL`로 전수 실측했다(`-L` 없이는 `num_redirects`가 항상 0이다 — AIF G-30). ⚠️ **집계를 손으로 세지 않았다** — 세 노트에서 마크다운 인라인 링크를 정규식으로 추출해 중복을 제거한 뒤 다시 측정했고(**34건**), 처음 손으로 적은 수(36)가 틀려 이 값으로 고쳤다.

**죽은 슬러그(이 노트가 인용하지 않는다):**

| 슬러그 | 신호 | 판정 |
| --- | --- | --- |
| `waf/latest/developerguide/waf-marketplace-rule-groups.html` | `200 r=1` → 가이드 인덱스 | 페이지 소멸. 정본은 `marketplace-rule-groups.html`(접두사 `waf-` 없음) |
| `securityhub/latest/userguide/what-is-security-hub.html` | `200 r=1` → 가이드 인덱스 | **신 Security Hub의 what-is는 이 슬러그가 아니다**(§2) |
| `organizations/latest/userguide/declarative_policies.html` | `200 r=1` → 가이드 인덱스 | 접두사가 빠진 슬러그. 정본은 `orgs_manage_policies_declarative_policies.html`(94 참조) |
| `kms/latest/developerguide/custom-key-store-overview.html` | `200 r=1` → 가이드 인덱스 | 페이지 소멸. ⚠️ **AWS Go SDK 문서가 아직 이 URL을 링크한다**(95 참조) |
| `detective/latest/adminguide/what-is-detective.html` | **`200 r=2`** → `detective/latest/userguide/` | **가이드 이름 변경**(adminguide → userguide). 2026-10-29 SOA·DEA 감사가 같은 결론에 닿았다 |

**대조군 4종 — 세 갈래 신호가 그대로 재현됐다:**

| 대조군 | 신호 |
| --- | --- |
| 세 노트가 인용하는 URL **34건 전부**(93편 15 · 94편 8 · 95편 11, 고유) | `200 r=0` |
| 살아 있는 가이드 안의 **없는 슬러그** 3건(`kms`·`securityhub`·`organizations`에 각 1) | `200 r=1` → **그 가이드의 인덱스** |
| **없는 가이드 접두사** 1건(`zz-no-such-guide/`) | **진짜 `404 r=0`** |
| 추측한 슬러그 1건(`kms/.../choose-keystore.html`) | `200 r=1` → 인덱스. **정본은 `key-store-overview.html`**이다 |

⚠️⚠️ **「소멸」과 「이름 변경」은 `num_redirects`로 갈라지지 않는다 — 도착지로 갈라진다.** 죽은 슬러그와 일부러 틀린 대조군이 **같은 신호**(`r=1` → 인덱스)를 주고, **특정 페이지**로 가면 이름 변경이다. `detective`의 `r=2`는 이 트랙에서 처음 본 값이고 **가이드 수준 이동**을 뜻한다.
⚠️ **내가 추측한 슬러그가 하나 죽어 있었다.** 본문의 링크 텍스트("Choosing the right key store")를 슬러그로 삼았는데 틀렸고, **실측이 없었으면 죽은 URL을 인용했다.** 링크 텍스트에서 슬러그를 유도하지 않는다.

## 9. 단정하지 않는 것

1. **OCSF 버전 숫자를 묻지 않는다**(§4-3) — 올라가는 값이다.
2. **GuardDuty 보호 플랜의 「개수」를 묻지 않는다** — 조회 시점에 9종이지만 늘어난다. 묻는다면 **어느 플랜이 어느 소스를 보는가**다.
3. **Detective가 Security Lake에서 세 소스를 모두 당겨온다고 적지 않는다**(§3.4) — 공식이 둘만 적는다.
4. **Security Hub 두 제품의 활성화 선후 관계를 단정하지 않는다** — 이 노트의 실측 범위 밖이다(§2는 둘이 다른 제품임까지만 고정한다).
5. **「소개 페이지가 그 사실을 담는지」를 확인한 것만 인용한다** — 이 레포가 반복해 밟은 결함이다(SAA §4-9).
