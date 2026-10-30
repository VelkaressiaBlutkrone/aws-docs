---
examGuideTaskId: dea-t4-2
certCode: DEA-C01
domain: 4
domainName: 데이터 보안 및 거버넌스
domainWeightPct: 18
title: 권한 부여 메커니즘 적용 (사용자 지정 정책·Lake Formation·RBAC/ABAC·최소 권한)
coversTasks:
  - "4.2"
sources:
  - title: Managed policies and inline policies (IAM User Guide) (공식 문서)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html
  - title: Security best practices in IAM (공식 문서)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html
  - title: PutParameter (AWS Systems Manager API Reference) (공식 문서)
    url: https://docs.aws.amazon.com/systems-manager/latest/APIReference/API_PutParameter.html
  - title: Storing connection credentials in AWS Secrets Manager (AWS Glue) (공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/connection-properties-secrets-manager.html
  - title: Row-level security (Amazon Redshift Database Developer Guide) (공식 문서)
    url: https://docs.aws.amazon.com/redshift/latest/dg/t_rls.html
  - title: Overview of Lake Formation permissions (공식 문서)
    url: https://docs.aws.amazon.com/lake-formation/latest/dg/lf-permissions-overview.html
  - title: Lake Formation tag-based access control (공식 문서)
    url: https://docs.aws.amazon.com/lake-formation/latest/dg/tag-based-access-control.html
  - title: Hybrid access mode (AWS Lake Formation Developer Guide) (공식 문서)
    url: https://docs.aws.amazon.com/lake-formation/latest/dg/hybrid-access-mode.html
  - title: IAM Access Analyzer policy generation (공식 문서)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-policy-generation.html
  - title: DEA-C01 공식 시험 가이드 도메인 4 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html
lastVerified: 2026-10-20
---

# 권한 부여 메커니즘 적용 (사용자 지정 정책·Lake Formation·RBAC/ABAC·최소 권한)

> **커버하는 공식 Task** — DEA-C01 · 도메인 4 「데이터 보안 및 거버넌스」(18%) · **Task 4.2 권한 부여 메커니즘 적용** (`dea-t4-2`)
> Task 4.1이 "들어올 길과 신분"이었다면 이 Task는 **"무엇을 할 수 있는가"** 입니다. 인증 수단·네트워크 경로·IAM 역할 위임·정책 평가 논리는 **Task 4.1** 을 참조하세요.
> **Skill 4.2.5·4.2.6은 v1.1에서 개정**됐습니다(Knowledge → Skill). 특히 4.2.5에서 **'policy-based'가 빠졌습니다.**

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 4.2의 Skill 항목)

- [ ] **AWS 관리형·고객 관리형·인라인 정책**을 선택 기준으로 가른다
- [ ] **권한 경계와 SCP·RCP**가 권한을 부여하지 않는다는 점을 설명한다
- [ ] **Secrets Manager와 Parameter Store**(표준·고급)를 요구사항으로 가른다
- [ ] **파라미터 정책이 회전이 아니라는 점**을 안다
- [ ] Redshift의 **RBAC·열 수준 권한·RLS·DDM**을 "무엇을 제한하는가"로 가른다
- [ ] **IAM 임시 DB 자격 증명**(Redshift·RDS)의 만료를 구분한다
- [ ] **IAM 권한과 Lake Formation 권한이 함께 필요**함을 설명한다
- [ ] **데이터 필터**로 열·행·셀 수준 보안을 구현하는 조합을 안다
- [ ] **LF-TBAC와 명명된 리소스 방식·하이브리드 접근 모드**를 가른다
- [ ] **RBAC·ABAC·LF-TBAC** 를 시나리오로 고른다
- [ ] **Access Analyzer 정책 생성·검증·마지막 액세스 정보**를 구분한다

---

## 🎯 왜 중요한가

- 권한 문항은 **"어느 층에서 막는가"** 를 묻습니다. IAM·DB 엔진·Lake Formation은 **서로를 대체하지 않습니다.** 특히 데이터 레이크는 ⚠️ **IAM과 Lake Formation 검사를 모두 통과**해야 하므로, "Lake Formation 권한을 줬는데 실패" 문항이 단골입니다.
- **세분화 단위가 곧 정답입니다.** Redshift에서 "행"은 RLS, "열"은 열 수준 권한, "값의 표시"는 DDM입니다. Lake Formation에서는 **필터를 어떻게 채우는가**가 행·열·셀을 결정합니다.
- **"권한을 주지 않는 장치"** 를 알아야 오답을 걸러냅니다 — 권한 경계·SCP·RCP는 **상한과 가드레일**일 뿐입니다.
- 자격 증명 저장소 문항은 **"자동 교체가 필요한가"** 한 줄로 갈립니다. ⚠️ **Parameter Store의 파라미터 정책은 회전이 아닙니다.**

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **관리형 정책** | managed policy | 여러 주체에 재사용할 수 있는 독립 정책 |
| **인라인 정책** | inline policy | 한 ID와 일대일로 묶인 정책 |
| **권한 경계** | permissions boundary | ID 기반 정책이 줄 수 있는 최대 권한의 상한 |
| **SCP·RCP** | service/resource control policy | 조직·OU·계정 수준의 가드레일 |
| **RBAC** | role-based access control | 역할(직무) 단위로 권한을 묶는 방식 |
| **ABAC** | attribute-based access control | 태그(속성) 일치로 권한을 정하는 방식 |
| **RLS** | row-level security | 사용자·역할이 어떤 행을 볼지 정하는 정책 |
| **DDM** | dynamic data masking | 저장 데이터는 그대로 두고 질의 시 표시 방식을 바꾸는 것 |
| **LF-Tag** | Lake Formation tag | Lake Formation이 권한 부여에 쓰는 전용 태그 |
| **데이터 필터** | data filter | Data Catalog 테이블에 행·열·셀 제한을 걸어 두는 정의 |
| **리소스 링크** | resource link | 공유받은 리소스를 내 카탈로그에서 가리키는 참조 |

---

## 📖 핵심 개념

### 1) 사용자 지정 IAM 정책 — 유형·조건·권한 경계 {#custom-policies}

AWS 관리형 정책이 요구에 맞지 않을 때 직접 정책을 만드는 선택지와 **그 범위를 좁히는 장치**를 묻습니다.

- **AWS 관리형 정책** — AWS가 만들고 관리하며 ⚠️ **권한을 바꿀 수 없습니다.** AWS가 권한을 업데이트하면 **정책이 붙은 모든 주체에 영향**이 갑니다. 널리 쓰는 **직무 기능에 맞춘** 정책들이 여기 속합니다(RBAC의 한 예).
- **고객 관리형 정책** — 내 계정에 만들어 여러 주체에 붙이는 독립 정책이며, **기존 AWS 관리형 정책을 복사해 시작**하는 방법이 좋습니다.
- **인라인 정책** — ⚠️ **단일 IAM 자격 증명(사용자·그룹·역할)과 일대일**로 묶이고 **자격 증명을 삭제하면 함께 삭제**됩니다. 정책이 **둘 이상의 엔터티에 적용될 수 있으면 관리형이 낫습니다.**
- ⚠️ **왜 사용자 지정인가** — AWS 관리형 정책은 모든 고객이 쓰도록 만들어져 **특정 사용 사례에 최소 권한이 아닐 수 있으므로**, 고객 관리형 정책으로 권한을 더 줄이라고 권고합니다.
- **조건(Condition)** — 정책 문이 유효한 조건을 지정합니다(예: 모든 요청이 TLS로 와야 한다). 한 Condition 블록의 **모든 컨텍스트 키가 true로 평가되어야** 효과가 발동하고, **연산자나 키가 여러 개면 AND, 한 키의 값이 여러 개면 OR** 로 평가됩니다.
- **권한 경계** — 관리형 정책으로 **ID 기반 정책이 IAM 엔터티에 부여할 수 있는 최대 권한**을 설정하는 기능이며 ⚠️ **권한 경계 자체는 권한을 주지 않습니다.** 개발자에게 역할 생성·관리를 위임하되 최대 권한을 제한할 때 씁니다.
- **조직 수준 가드레일** — SCP·RCP로 조직·OU·계정 수준 가드레일을 세우지만 ⚠️ **SCP·RCP는 권한을 부여하지 못하므로** ID 기반 또는 리소스 기반 정책이 따로 필요합니다.

| 구분 | 누가 관리·수정 | 적용 대상 | 시험 단서 |
|---|---|---|---|
| **AWS 관리형 정책** | AWS(**수정 불가**) | 여러 주체 | "빠른 시작", **"최소 권한 아닐 수 있음"** |
| **고객 관리형 정책** | 사용자(수정 가능) | 여러 주체 | "여러 역할에 같은 맞춤 권한", "관리형을 복사해 축소" |
| **인라인 정책** | 사용자(수정 가능) | **단일 ID와 일대일** | "이 역할에만", "ID 삭제 시 함께 삭제" |
| **권한 경계** | 사용자 | IAM 사용자·역할 | "역할 생성 위임 + **최대 권한 제한**" |
| **SCP·RCP** | 조직 관리자 | 조직·OU·계정 | **"권한을 주지 않는 가드레일"** |

### 2) 자격 증명 저장 — Secrets Manager vs Parameter Store {#credential-stores}

"비밀을 코드에서 빼낸다"는 같은 목적을 두 서비스가 **다른 기능·비용 구조**로 풉니다. 회전 메커니즘 자체(관리형 회전·Lambda 회전·스테이징 레이블)는 **Task 4.1** 을 참조하세요.

- **Secrets Manager** — 비밀을 **회전하고 관리하고 조회**하는 서비스입니다. **저장한 비밀 수와 API 호출 수로 과금**하고 ⚠️ **회전으로 만든 새 버전에는 과금하지 않습니다.** 비밀 값은 텍스트·바이너리 모두 **최대 65,536바이트**까지 저장합니다.
- **Parameter Store** — **표준과 고급** 두 티어가 있습니다. 표준은 **값 4 KB·계정/리전당 10,000개·추가 비용 없음·파라미터 정책 불가**이고, 고급은 **값 8 KB·계정/리전당 100,000개·요금 발생·파라미터 정책 가능**입니다. ⚠️ **표준→고급 변경은 언제든 가능하지만 고급→표준으로 되돌릴 수 없습니다.**
- ⚠️ **파라미터 정책은 회전이 아닙니다** — 지원하는 정책 유형은 **Expiration(만료 시 삭제)·ExpirationNotification·NoChangeNotification** 뿐입니다. 파라미터는 **최근 100개 버전**을 유지합니다.
- **SecureString** — KMS 키로 암호화하며 키 ID를 지정하지 않으면 **계정 기본 키**를 쓰는데 사용자 지정 키보다 안전하지 않다고 안내합니다.
- **계정 간 공유** — **고급 파라미터**를 **AWS RAM** 으로 다른 계정과 공유합니다.
- **Glue 연결과 Secrets Manager** — 데이터 스토어 연결 자격 증명은 **Secrets Manager에 두는 것을 권장**하며 Glue가 **ETL 작업·크롤러 실행 시점에 비밀을 조회**합니다. ⚠️ **Glue용 IAM 역할에 비밀 조회 권한을 줘야 하고 `AWSGlueServiceRole` 관리형 정책에는 Secrets Manager 권한이 없습니다.** 네트워크 구성에 따라 Secrets Manager VPC 엔드포인트가 필요할 수 있습니다.

| 항목 | **Secrets Manager** | **Parameter Store 표준** | **Parameter Store 고급** |
|---|---|---|---|
| 핵심 용도 | 비밀의 **회전**·관리·조회 | 일반 파라미터(값 4 KB 이하) | 큰 값·정책·계정 간 공유 |
| 값 크기 | 최대 **65,536바이트** | **4 KB** | **8 KB** |
| 개수 한도(계정·리전당) | — | **10,000개** | **100,000개** |
| 자동 회전 | **지원** | **회전 유형의 정책 없음** | **회전 유형의 정책 없음** |
| 요금 | 비밀 수 + API 호출 수 | **추가 비용 없음** | 요금 발생 |
| 파라미터 정책 | 해당 없음 | **불가** | 가능(만료·알림) |
| 계정 간 공유 | 리소스 정책 + KMS 키(4.1 참조) | — | **AWS RAM** |
| 시험 단서 | "자동 교체", "DB 자격 증명", "Glue 연결 자격 증명" | "무료", "구성 값" | "4 KB 초과", "정책", "계정 간 공유" |

### 3) 데이터베이스 사용자·그룹·역할 권한 — Amazon Redshift {#db-permissions}

- **RBAC(역할 기반)** — 권한을 역할에 모아 사용자에게 부여해 보안 권한 관리를 단순화하고, ⚠️ **권한 부여·회수를 개별 객체가 아니라 역할 수준**에서 합니다. 역할에 권한을 나눠 담으면 사용자는 역할이 허용한 작업만 할 수 있어 **최소 권한 원칙**이 적용됩니다.
- **열 수준 + 행 수준(RLS)** — **열 수준 보안**으로 일부 열에만 권한을 주고, **RLS 정책**으로 **보이는 열의 특정 행**까지 추가로 제한합니다. RLS는 사용자나 역할이 스키마·테이블 안의 **어떤 레코드에 접근할 수 있는지**를 객체 수준 보안 정책으로 정합니다.
- **동적 데이터 마스킹(DDM)** — ⚠️ **데이터를 변형하지 않고 쿼리 시점에 민감 데이터가 보이는 방식**을 바꿉니다. 마스킹 정책은 특정 **사용자나 역할**에 적용하며 **조건부 열로 셀 수준 마스킹**도 가능하고, ⚠️ **같은 열에 여러 정책이 걸리면 적용 우선순위로 충돌을 해결**합니다. (마스킹 상세·제약은 `dea-t4-3` 참조)
- **IAM 기반 임시 DB 자격 증명** — `GetClusterCredentials` 는 임시 DB 사용자 이름과 암호를 돌려주며 **기본 만료는 900초**이고 **900~3600초** 범위에서 지정할 수 있습니다.
- **RDS IAM 데이터베이스 인증** — 암호 대신 **인증 토큰**을 쓰며 토큰은 ⚠️ **생성 후 15분간 유효**하고 코드에 암호를 넣지 않아도 됩니다.

| 제어 수단 | 무엇을 제한하나 | 부여 단위 | 시험 단서 |
|---|---|---|---|
| **RBAC** | 역할에 모은 권한 | 역할 → 사용자 | "권한 변경을 역할 한 곳에서" |
| **열 수준 권한** | 접근 가능한 **열** | 사용자에게 열 단위로 부여 | "일부 열만 조회" |
| **RLS** | 접근 가능한 **행** | 정책을 사용자/역할에 연결 | "팀·리전별로 보이는 행이 다름" |
| **DDM** | **값이 보이는 방식**(원본 불변) | 마스킹 정책 + 우선순위 | "카드 번호 일부만 표시", "셀 단위 조건부" |
| **IAM 임시 자격 증명** | 로그인 자격 증명 | IAM 정책 + `GetClusterCredentials` | "암호 없이 IAM으로 DB 접속" |

### 4) Lake Formation 권한 관리 {#lake-formation}

데이터 레이크의 Data Catalog 리소스와 S3 기반 데이터를 한 곳에서 **GRANT/REVOKE** 로 관리하고, 통합 서비스(Athena·Redshift Spectrum·EMR·Glue)가 그 권한을 따릅니다.

- **두 종류 권한** — **메타데이터 접근(Data Catalog 권한)** 과 **기반 데이터 접근(S3 위치의 데이터 접근·데이터 위치 권한)** 이며, 모델은 **DBMS 스타일 GRANT/REVOKE 명령**으로 구현됩니다.
- ⚠️ **IAM 권한과 Lake Formation 권한은 함께 필요합니다.** 요청이 성공하려면 **IAM과 Lake Formation 검사를 모두 통과**해야 하고, IAM 권한은 **Lake Formation·Glue API와 리소스 접근**을, Lake Formation 권한은 **Data Catalog 리소스·S3 위치·기반 데이터 접근**을 통제합니다. ⚠️ **Lake Formation 권한은 부여한 리전에서만 유효**합니다.
- **S3 위치 등록** — Lake Formation이 기반 데이터 접근을 통제하려면 **S3 위치를 등록하고 읽기/쓰기 권한이 있는 IAM 역할을 지정**합니다. 통합 서비스가 접근을 요청하면 Lake Formation이 **그 역할로 임시 자격 증명을 공급**합니다. ⚠️ 위치는 **버킷이나 버킷 아래 프리픽스**이고 **개별 S3 객체는 아닙니다.**
- **LF-TBAC(태그 기반)** — **LF-Tag를 Data Catalog 리소스에 붙이고 그 태그로 주체에게 권한을 부여**하는 인가 전략이며 ⚠️ **리소스가 많을 때 권장되는 방법**입니다. ⚠️ **IAM 태그와 LF-Tag는 같지 않으며 서로 바꿔 쓸 수 없습니다.**
- **데이터 필터(행·열·셀)** — 데이터 필터로 **열·행·셀 수준 보안**을 구현하고, 각 필터는 **하나의 Data Catalog 테이블에 속합니다.** 한 테이블에 필터를 여러 개 만들어 두고 **테이블 권한을 부여할 때 하나 이상을 골라** 씁니다.

  **필터를 채우는 방식이 보안 수준을 결정합니다 — 이 조합을 외우세요.**

  | 열 선택 | 행 선택 | 결과 보안 수준 |
  |---|---|---|
  | **"모든 열" 와일드카드** | 행 필터 표현식 | **행 수준** |
  | 특정 열 포함/제외 | **"모든 행"** | **열 수준** |
  | 특정 열 포함/제외 | 행 필터 표현식 | **셀 수준** |

  ⚠️ **필터는 읽기 작업에만 적용되므로 필터와 함께 부여할 수 있는 Lake Formation 권한은 SELECT뿐입니다.**
- **교차 계정 공유** — **명명된 리소스 방식이나 LF-Tag** 로 계정 간 공유를 하고, Lake Formation은 **AWS RAM** 으로 계정 간 권한 부여를 처리합니다. ⚠️ **수신 계정에서 Athena나 Redshift Spectrum으로 조회하려면 공유 리소스에 대한 리소스 링크가 필요**합니다.
- **하이브리드 접근 모드** — 같은 Data Catalog 객체에 **두 가지 권한 경로**를 제공합니다. ⚠️ **옵트인한 주체는 Lake Formation 권한과 IAM 권한을 모두 요구받고, 옵트인하지 않은 주체는 기존처럼 IAM 권한만으로 접근**합니다. 그래서 **다른 기존 사용자·워크로드의 접근을 끊지 않고 일부 사용자에게만 점진 도입**할 수 있습니다.

| 비교 | **IAM 권한** | **Lake Formation 권한** |
|---|---|---|
| 통제 대상 | Lake Formation·Glue **API와 리소스 접근** | **Data Catalog 리소스, S3 위치, 기반 데이터** |
| 표현 방식 | IAM 정책 | **DBMS 스타일 GRANT/REVOKE** |
| 세분화 | 정책 문으로 작업·리소스·조건 | 데이터베이스·테이블·열, **데이터 필터로 행·셀** |
| 관계 | **둘 다 통과해야 접근 성공** | 둘을 조합해 사용 |
| 시험 단서 | "Glue API 호출 권한 오류" | "열·행·셀 단위", "LF-Tag", "교차 계정 공유(RAM)" |

### 5) 권한 부여 방식 — 역할 기반·태그 기반·속성 기반 {#authz-methods}

> 📌 **v1.1 개정(Skill 4.2.5)** — v1.0의 지식 항목 'Authorization methods (role-based, **policy-based**, tag-based, and attribute based)'가 v1.1에서 Skill 'Apply authorization methods that address business needs (role-based, tag-based, and attribute-based)'로 통합되면서 ⚠️ **'policy-based'가 빠졌습니다.** 개정 페이지는 **이유를 적지 않습니다.**

- **역할 기반(RBAC)** — 역할(직무) 단위로 권한을 묶습니다. IAM에서는 **직무 기능에 맞춘 AWS 관리형 정책**이 한 예이고, Redshift에서는 **역할에 권한을 모아 사용자에게 부여**합니다.
- **속성 기반(ABAC)** — **속성에 따라 권한을 정의하는 인가 전략**으로 ⚠️ **AWS에서 속성은 태그**이며 AWS 리소스, IAM 역할, 역할 세션에 정의합니다. ⚠️ **역할이나 세션의 태그가 리소스의 태그와 일치하도록 요구**해 세분화된 권한을 줄 수 있고, **빠르게 성장하는 환경에 유용**합니다.
- **태그 기반(Lake Formation)** — **LF-TBAC** 가 데이터 레이크 쪽 태그 기반 방식입니다(위 4절).
- ⚠️ **ABAC의 가드레일** — ABAC는 태그에 의존하므로 **의도치 않은 접근을 막는 가드레일이 중요**하고, 조직 전체에서 **태그 수정 조건을 제한하는 데 SCP를 쓸 수 있습니다.** (태그를 바꿀 수 있는 권한이 곧 접근 권한입니다)

| 방식 | 권한의 기준 | 예 | 장점 |
|---|---|---|---|
| **RBAC** | 직무·역할 | IAM 직무 기능 관리형 정책, Redshift 역할 | 역할 수준에서 권한 관리 단순화 |
| **ABAC(IAM)** | **주체·리소스의 태그 일치** | 역할/세션 태그 = 리소스 태그 | **새 리소스가 생겨도 정책 수정을 줄임** |
| **LF-TBAC** | **LF-Tag 값 일치** | 분류(Confidential 등) 태그로 테이블·열 권한 | 대규모 Data Catalog에서 관리 부담 감소 |

### 6) 최소 권한 정책 구성 {#least-privilege}

> 📌 **v1.1 개정(Skill 4.2.6)** — v1.0의 지식 항목 'Principle of least privilege as it applies to AWS security'가 **'Construct custom policies that meet the principle of least privilege'** 로 바뀌었습니다(**정책 작성**으로 이동). 개정 페이지는 이유를 적지 않습니다.

- **정의와 출발점** — **작업에 필요한 권한만 부여**하는 것이 최소 권한입니다. 처음에는 넓게 시작하고 **사용 사례가 성숙하면 줄여** 나가며, **AWS 관리형 정책에서 시작해 고객 관리형 정책으로 줄입니다.**
- **정책 생성(Access Analyzer)** — ⚠️ **CloudTrail에 기록된 접근 활동으로 정책을 생성**합니다. IAM Access Analyzer가 CloudTrail 로그를 검토해 **지정한 기간에 엔터티가 쓴 권한을 담은 정책 템플릿**을 만들고, 이를 **테스트한 뒤 프로덕션에 배포**합니다.
- **마지막 액세스 정보** — 필요 없는 사용자·역할·권한·정책·자격 증명을 찾아 제거하고, IAM 정책을 최소 권한에 맞게 다듬는 데 씁니다.
- **정책 검증(Access Analyzer)** — 정책 언어와 모범 사례를 점검하는 **정책 검사를 100개가 넘게 제공**하고 조치 가능한 권고를 줍니다.
- **공개·교차 계정 액세스 검증** — Access Analyzer가 **공개·교차 계정 액세스를 허용하는 지원 리소스에 대해 결과(finding)를 생성**합니다. (정책이 아니라 **탐지 결과**입니다)
- **조건·경계·가드레일** — 조건으로 허용 범위를 좁히고(예: TLS 요청만), 권한 경계로 위임 권한의 최대치를 정하며, SCP·RCP로 여러 계정에 가드레일을 세웁니다(**권한 자체는 부여하지 않음**).

| 도구 | 하는 일 | 시험 단서 |
|---|---|---|
| **Access Analyzer 정책 생성** | **CloudTrail 활동 기반 정책 템플릿** | "지난 N일 사용 내역으로 최소 권한 정책" |
| **Access Analyzer 정책 검증** | 정책 문법·모범 사례 검사(**100개 이상**) | "작성한 정책이 안전하고 기능적인지 점검" |
| **마지막 액세스 정보** | 쓰지 않는 권한·자격 증명 식별 | "사용하지 않는 권한 제거" |
| **공개·교차 계정 findings** | 외부 접근 허용 리소스 **탐지** | "의도치 않은 외부 접근" |
| **권한 경계 / SCP·RCP** | **최대 권한 제한 / 조직 가드레일** | "권한을 주지 않고 상한만" |

---

## ✍️ 시험 포인트

1. **"Lake Formation 권한을 줬는데도 실패"** → **IAM 권한(Glue API 등)도 필요**합니다. 두 검사를 모두 통과해야 합니다.
2. **필터 조합으로 보안 수준 판정** — 모든 열 + 행 표현식 = **행 수준**, 특정 열 + 모든 행 = **열 수준**, 특정 열 + 행 표현식 = **셀 수준**. 필터와 함께 부여할 수 있는 권한은 **SELECT뿐**입니다.
3. **"기존 ETL·사용자를 끊지 않고 일부만 Lake Formation 권한 도입"** → **하이브리드 접근 모드(옵트인)**.
4. **"공유했는데 Athena로 조회가 안 됨"** → 수신 계정의 **리소스 링크**가 없습니다.
5. **"수백 개 테이블을 분류 태그로 관리"** → **LF-TBAC**. ⚠️ **IAM 태그로는 안 됩니다**(호환 불가).
6. **"새 리소스가 계속 생기는데 정책 수정을 최소화"** → **ABAC**(주체·리소스 태그 일치). 이때 **태그 수정 권한을 SCP로 통제**해야 합니다.
7. **Redshift 세분화는 단위로 가르기** — "행이 다름" → **RLS**, "일부 열만" → **열 수준 권한**, "원본은 그대로 두고 가려서 표시" → **DDM**.
8. **임시 자격 증명 만료** — Redshift `GetClusterCredentials` **기본 900초(900~3600초)**, RDS IAM 인증 토큰 **15분**.
9. **"자동 교체 + Glue가 실행 시점에 조회"** → **Secrets Manager**. ⚠️ **`AWSGlueServiceRole` 에는 Secrets Manager 권한이 없어** 별도 부여가 필요합니다.
10. **"만료 알림"을 "자동 회전"으로 착각하지 않기** — Parameter Store 정책은 **Expiration·ExpirationNotification·NoChangeNotification** 뿐입니다.
11. **"과다 권한 역할을 실제 사용 내역에 맞게 축소"** → **Access Analyzer 정책 생성**(CloudTrail 기반). 권한 경계나 SCP는 **정책을 만들어 주지 않습니다.**

---

## ⚠️ 흔한 함정

1. **AWS 관리형 정책을 그대로 최소 권한이라고 가정** — 모든 고객용이라 **특정 사례에 최소 권한이 아닐 수 있습니다.**
2. **인라인 정책을 여러 역할에 재사용하려 함** — 인라인은 **단일 ID와 일대일**입니다. 재사용은 고객 관리형입니다.
3. **ID를 삭제했는데 인라인 정책이 남을 것으로 기대** — **함께 삭제**됩니다.
4. **권한 경계·SCP·RCP를 붙이면 권한이 부여된다고 생각** — **권한을 주지 않는 상한·가드레일**입니다.
5. **Condition 블록의 키 하나만 맞으면 된다고 생각** — **모든 컨텍스트 키가 true** 여야 효과가 발동합니다.
6. **Parameter Store 파라미터 정책으로 자동 회전을 설정** — 정책 유형은 **만료·알림**뿐이며 **회전이 아닙니다.**
7. **표준 파라미터에 큰 값·정책·공유를 기대** — 표준은 **4 KB·정책 불가**이고 공유는 **고급 + AWS RAM** 입니다.
8. **고급 → 표준으로 되돌리려 함** — ⚠️ **되돌릴 수 없습니다.**
9. **`AWSGlueServiceRole` 만 붙이면 비밀을 읽을 수 있다고 가정** — ⚠️ **이 관리형 정책에는 Secrets Manager 권한이 없습니다.**
10. **RLS로 열을 숨기려 함** — RLS는 **행**, 열은 **열 수준 권한**입니다.
11. **마스킹을 위해 원본 데이터를 변형** — **DDM은 데이터를 변형하지 않고** 쿼리 시점 표시만 바꿉니다.
12. **같은 열의 여러 마스킹 정책이 모두 적용된다고 생각** — **적용 우선순위**로 충돌을 해결합니다.
13. **임시 자격 증명 만료를 한 값으로 외움** — Redshift **기본 900초(900~3600초)**, RDS 토큰 **15분**입니다.
14. **Lake Formation 권한만 주고 IAM 권한을 생략** — **두 검사를 모두 통과**해야 합니다.
15. **Lake Formation 권한이 전 리전에서 유효하다고 생각** — ⚠️ **부여한 리전에서만** 유효합니다.
16. **S3 위치 등록 없이 기반 데이터 통제를 기대** — 위치를 등록해야 Lake Formation이 **임시 자격 증명으로 접근을 통제**합니다.
17. **개별 S3 객체를 Lake Formation 위치로 등록하려 함** — 위치는 **버킷이나 프리픽스**입니다.
18. **IAM 태그를 LF-Tag로 오인** — **서로 다르며 호환되지 않습니다.**
19. **데이터 필터로 쓰기 권한까지 제한하려 함** — ⚠️ **필터는 읽기 작업에만** 적용되고 부여 가능한 권한은 **SELECT뿐**입니다.
20. **한 필터를 여러 테이블에 재사용하려 함** — 각 필터는 **하나의 Data Catalog 테이블에 속합니다.**
21. **RAM 공유 수락만으로 조회가 된다고 생각** — Athena·Redshift Spectrum은 **리소스 링크**가 필요합니다.
22. **하이브리드 모드에서 모든 주체가 Lake Formation 권한을 요구받는다고 생각** — **옵트인한 주체만**이고 나머지는 **IAM만**으로 계속 접근합니다.
23. **ABAC에서 태그 수정 권한을 방치** — **태그가 곧 권한**이므로 가드레일(SCP)이 필요합니다.
24. **Access Analyzer의 공개·교차 계정 finding을 정책으로 사용** — finding은 **탐지 결과**이고 정책 템플릿은 **정책 생성** 기능이 만듭니다.
25. **정책 생성과 정책 검증을 혼동** — **생성은 CloudTrail 활동 기반 템플릿**, **검증은 문법·모범 사례 검사(100개 이상)** 입니다.
26. **v1.1에서 'policy-based'가 남아 있다고 생각** — Skill 4.2.5에서 **빠졌습니다.**

---

## 🧪 자가 점검

**Q1.** AWS Glue ETL 작업이 쓰는 JDBC 데이터베이스 자격 증명을 안전하게 저장하려 한다. 보안 팀은 암호를 정기적으로 자동 교체하고, 코드나 스크립트에 암호가 남지 않기를 요구한다. 가장 적절한 구성은?

<details><summary>정답 보기</summary>

**비밀을 Secrets Manager에 저장하고 Glue 연결이 그 비밀을 참조하게 하며, Glue 역할에 비밀 조회 권한을 부여합니다.** Glue는 연결 자격 증명을 **실행 시점에 Secrets Manager에서 조회**하도록 권장하고 Secrets Manager는 비밀 회전을 제공합니다. ⚠️ **`AWSGlueServiceRole` 관리형 정책에는 Secrets Manager 권한이 없으므로** 별도로 부여해야 합니다. Parameter Store의 **파라미터 정책은 만료·알림이며 회전이 아닙니다.**
</details>

**Q2.** Amazon Redshift의 `customers` 테이블을 영업팀과 마케팅팀이 조회한다. 영업팀 분석가는 자기 리전의 행만 보아야 하고, 마케팅팀은 모든 행을 보되 신용카드 번호는 가려진 값으로 보아야 한다. 원본 데이터는 바꾸면 안 된다. 어떻게 구성하는가?

<details><summary>정답 보기</summary>

**영업팀 역할에 RLS 정책을, 마케팅팀 역할에 DDM 마스킹 정책을 연결합니다.** RLS는 **보이는 열의 특정 행**으로 접근을 제한하고, DDM은 **데이터를 변형하지 않고 쿼리 시점에 표시 방식을 바꾸는** 마스킹 정책을 사용자·역할에 적용합니다. 열 수준 권한은 **열만** 제한하므로 행 제한·값 마스킹을 하지 못하고, 원본 열을 해시로 갱신하는 것은 **원본 변경 금지 요구를 위반**합니다.
</details>

**Q3.** 회사는 Glue Data Catalog 테이블에 IAM 정책과 S3 권한만으로 ETL 작업이 접근해 왔다. 이제 일부 분석가에게만 Lake Formation의 열·행 수준 권한을 적용하고 싶지만 기존 ETL 작업과 다른 사용자의 접근이 끊기면 안 된다. 어떻게 하는가?

<details><summary>정답 보기</summary>

**하이브리드 접근 모드를 사용하고 해당 분석가만 Lake Formation 권한을 쓰도록 옵트인합니다.** 하이브리드 접근 모드는 같은 Data Catalog 객체에 **두 가지 권한 경로**를 제공합니다. **옵트인한 주체만 Lake Formation 권한과 IAM 권한을 모두 요구받고**, 옵트인하지 않은 기존 사용자·워크로드는 **IAM 권한만으로 계속 접근**하므로 접근이 끊기지 않습니다. 전면 전환은 이 모드를 쓰는 이유와 정반대입니다.
</details>

**Q4.** 데이터 레이크 테이블에 분류 태그(예: Confidential)를 붙여 수백 개 테이블과 많은 분석가의 접근을 관리하려 한다. 새 테이블이 추가되어도 권한을 개별로 다시 부여하지 않고 태그 값 일치로 적용되길 원한다. 가장 적합한 방식은?

<details><summary>정답 보기</summary>

**Lake Formation LF-TBAC를 사용합니다 — LF-Tag를 리소스와 주체에 붙이고 태그 값으로 권한을 부여합니다.** LF-TBAC는 속성(LF-Tag)에 따라 권한을 정하는 인가 전략으로, **Data Catalog 객체가 많을 때 권장되는 방법**입니다. ⚠️ **IAM 태그와 LF-Tag는 같지 않고 호환되지 않으므로** IAM 태그를 붙여도 Lake Formation이 그것으로 권한을 집행하지 않습니다. 테이블마다 명명된 리소스로 개별 부여하면 리소스가 많을수록 부담이 커집니다.
</details>

**Q5.** Glue ETL 작업의 IAM 역할이 개발 초기에 AWS 관리형 정책으로 광범위한 권한을 받은 채 운영 중이다. 보안 팀은 **최근 실제로 사용한** 작업과 리소스에 맞춘 최소 권한 정책으로 교체하길 원한다. 어떻게 하는가?

<details><summary>정답 보기</summary>

**IAM Access Analyzer 정책 생성으로 CloudTrail 접근 활동 기반 정책 템플릿을 만들고, 테스트한 뒤 배포합니다.** Access Analyzer는 **CloudTrail 로그를 검토해 지정한 기간에 엔터티가 쓴 권한을 담은 정책 템플릿**을 만듭니다. 권한 경계는 **부여 가능한 최대 권한의 상한**일 뿐 사용 내역에 맞춘 정책을 만들지 않고, SCP·RCP는 **권한을 부여하지 않는 가드레일**이며, 공개·교차 계정 finding은 **외부 접근 허용 리소스를 알려 주는 탐지 결과**입니다.
</details>

---

**Q6 (원리).** 왜 데이터 레이크에서는 "IAM만" 또는 "Lake Formation만"으로 권한이 완성되지 않을까요?

<details><summary>정답 보기</summary>

**두 시스템이 서로 다른 대상을 통제하기 때문입니다.** IAM은 **API와 리소스에 대한 호출**(Lake Formation·Glue API를 부를 수 있는가)을 통제하고, Lake Formation은 **데이터 자체**(어느 데이터베이스·테이블·열·행을 읽을 수 있는가)를 통제합니다. 그래서 Lake Formation에서 `SELECT` 를 받아도 Glue API를 부를 IAM 권한이 없으면 작업이 실패하고, IAM으로 S3를 열어 놔도 위치가 등록돼 있으면 Lake Formation이 **임시 자격 증명을 공급하는 역할**을 통해 접근을 중개합니다. 이 구조가 왜 유용한지도 같은 이유에서 나옵니다 — **데이터에 접근하는 주체마다 S3·KMS 권한을 직접 주지 않아도** 되기 때문입니다. 그래서 문항에서 "권한을 줬는데 실패"가 나오면, 먼저 **어느 쪽 검사에서 걸렸는지**를 묻고 있다고 읽으면 됩니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-17 · 보강: 2026-10-19 · 저작: 2026-10-20 · 사람 검수 전)

1. Managed policies and inline policies (IAM User Guide) — https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html
2. Conditions with multiple context keys or values (IAM User Guide) — https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_condition-logic-multiple-context-keys-or-values.html
3. Security best practices in IAM — https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html
4. IAM Access Analyzer policy generation — https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-policy-generation.html
5. PutParameter (AWS Systems Manager API Reference) — https://docs.aws.amazon.com/systems-manager/latest/APIReference/API_PutParameter.html
6. Working with shared parameters in Parameter Store — https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-shared-parameters.html
7. AWS Secrets Manager pricing — https://aws.amazon.com/secrets-manager/pricing/
8. JSON structure of AWS Secrets Manager secrets — https://docs.aws.amazon.com/secretsmanager/latest/userguide/reference_secret_json_structure.html
9. Storing connection credentials in AWS Secrets Manager (AWS Glue Developer Guide) — https://docs.aws.amazon.com/glue/latest/dg/connection-properties-secrets-manager.html
10. Role-based access control (RBAC) (Amazon Redshift Database Developer Guide) — https://docs.aws.amazon.com/redshift/latest/dg/t_Roles.html
11. Row-level security (Amazon Redshift Database Developer Guide) — https://docs.aws.amazon.com/redshift/latest/dg/t_rls.html
12. Dynamic data masking (Amazon Redshift Database Developer Guide) — https://docs.aws.amazon.com/redshift/latest/dg/t_ddm.html
13. GetClusterCredentials (Amazon Redshift API Reference) — https://docs.aws.amazon.com/redshift/latest/APIReference/API_GetClusterCredentials.html
14. Connecting to your DB instance using IAM authentication (Amazon RDS User Guide) — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Connecting.html
15. Overview of Lake Formation permissions — https://docs.aws.amazon.com/lake-formation/latest/dg/lf-permissions-overview.html
16. Underlying data access control (AWS Lake Formation Developer Guide) — https://docs.aws.amazon.com/lake-formation/latest/dg/access-control-underlying-data.html
17. Lake Formation tag-based access control — https://docs.aws.amazon.com/lake-formation/latest/dg/tag-based-access-control.html
18. Managing data filters (AWS Lake Formation Developer Guide) — https://docs.aws.amazon.com/lake-formation/latest/dg/managing-filters.html
19. Cross-account data sharing in Lake Formation — https://docs.aws.amazon.com/lake-formation/latest/dg/cross-data-sharing-lf.html
20. Hybrid access mode (AWS Lake Formation Developer Guide) — https://docs.aws.amazon.com/lake-formation/latest/dg/hybrid-access-mode.html
21. AWS service integrations with Lake Formation — https://docs.aws.amazon.com/lake-formation/latest/dg/service-integrations.html
22. AWS Identity and Access Management (IAM) FAQs — https://aws.amazon.com/iam/faqs/
23. ABAC for individual resources (Tagging best practices whitepaper) — https://docs.aws.amazon.com/whitepapers/latest/tagging-best-practices/abac-for-individual-resources.html
24. Revisions (AWS Certified Data Engineer - Associate exam guide) — https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html
25. Data filtering and cell-level security in Lake Formation — https://docs.aws.amazon.com/lake-formation/latest/dg/data-filtering.html
26. DEA-C01 공식 시험 가이드 도메인 4 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html
