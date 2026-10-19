---
examGuideTaskId: dea-t4-5
certCode: DEA-C01
domain: 4
domainName: 데이터 보안 및 거버넌스
domainWeightPct: 18
title: 데이터 프라이버시·거버넌스 (Redshift 공유·Macie·리전 통제·Config·주권)
coversTasks:
  - "4.5"
sources:
  - title: Considerations for data sharing in Amazon Redshift (공식 문서)
    url: https://docs.aws.amazon.com/redshift/latest/dg/datashare-considerations.html
  - title: Sharing data across AWS accounts (Amazon Redshift) (공식 문서)
    url: https://docs.aws.amazon.com/redshift/latest/dg/across-account.html
  - title: AWS Lake Formation-managed datashares (Amazon Redshift) (공식 문서)
    url: https://docs.aws.amazon.com/redshift/latest/dg/lf_datashare_overview.html
  - title: Analyzing encrypted Amazon S3 objects (Amazon Macie) (공식 문서)
    url: https://docs.aws.amazon.com/macie/latest/user/discovery-supported-encryption-types.html
  - title: AWS global condition context keys (IAM User Guide) (공식 문서)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_condition-keys.html
  - title: Configure the Region deny control (AWS Control Tower User Guide) (공식 문서)
    url: https://docs.aws.amazon.com/controltower/latest/userguide/region-deny.html
  - title: AWS Config terminology and concepts (공식 문서)
    url: https://docs.aws.amazon.com/config/latest/developerguide/config-concepts.html
  - title: Definitions (AWS Well-Architected Digital Sovereignty Lens) (공식 문서)
    url: https://docs.aws.amazon.com/wellarchitected/latest/digital-sovereignty-lens/definitions.html
  - title: Approve or reject a subscription request in Amazon SageMaker Unified Studio (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/approve-reject-subscription-request.html
  - title: Reference architecture (data mesh; AWS Well-Architected Data Analytics Lens) (공식 문서)
    url: https://docs.aws.amazon.com/wellarchitected/latest/analytics-lens/data-mesh-reference-architecture.html
  - title: DEA-C01 공식 시험 가이드 도메인 4 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html
lastVerified: 2026-10-20
---

# 데이터 프라이버시·거버넌스 (Redshift 공유·Macie·리전 통제·Config·주권)

> **커버하는 공식 Task** — DEA-C01 · 도메인 4 「데이터 보안 및 거버넌스」(18%) · **Task 4.5 데이터 프라이버시 및 거버넌스 이해** (`dea-t4-5`)
> Skill 7개로 **주제가 가장 이질적**입니다. 세 덩이로 묶어 보세요 — **① 데이터 공유(4.5.1·4.5.6·4.5.7) · ② 프라이버시·리전·주권(4.5.2·4.5.3·4.5.5) · ③ 구성 변경 조회(4.5.4)**.
> **4.5.6·4.5.7은 v1.1 신규**, **4.5.4·4.5.5는 v1.1 개정**(Managing → **Viewing**, Knowledge → **Skill**)입니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 4.5의 Skill 항목)

- [ ] **Redshift 데이터 공유**의 프로듀서·소비자 권한 부여 절차를 설명한다
- [ ] **교차 계정 공유의 양방향 핸드셰이크**와 암호화 요건을 안다
- [ ] **Lake Formation 관리 datashare** 의 이점과 제약을 가른다
- [ ] **Macie의 두 검색 방식**과 **식별자 2종**을 구분한다
- [ ] Macie가 **분석할 수 있는 암호화와 못 하는 암호화**를 가른다
- [ ] **`aws:RequestedRegion` 의 한계**를 설명한다
- [ ] **Control Tower Region deny** 와 **S3 교차 리전 복제 금지** 를 가른다
- [ ] **데이터 상주와 데이터 주권**을 구분한다
- [ ] **AWS Config 구성 이력·aggregator·고급 쿼리**를 용도로 가른다
- [ ] **Config와 CloudTrail** 의 역할 분담을 설명한다
- [ ] **SageMaker Catalog 구독 승인 주체와 자산 유형별 이행**을 안다
- [ ] **데이터 메시 구조**와 공유 패턴 수단을 고른다

---

## 🎯 왜 중요한가

- 공유 문항은 **"복사하는가"** 로 갈립니다. **Redshift 데이터 공유는 수동 이동·복사 없이 라이브 데이터**를 공유하므로, 스냅샷 복원이나 UNLOAD/COPY 보기는 그 자체로 오답 신호입니다.
- 교차 계정 공유는 **양쪽이 모두 움직입니다** — ⚠️ **프로듀서 authorize + 소비자 associate** 의 **양방향 핸드셰이크**입니다.
- 리전 통제 문항의 함정은 하나입니다 — ⚠️ **`aws:RequestedRegion` 은 호출 엔드포인트만 통제하고 작업의 영향은 통제하지 않습니다.** 그래서 **S3 교차 리전 복제는 별도 컨트롤**이 필요합니다.
- Config vs CloudTrail은 **"어떻게 바뀌었나" vs "누가 바꿨나"** 입니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **datashare** | datashare | Redshift에서 *공유할 객체를 담는 그릇* |
| **프로듀서·소비자** | producer / consumer | 데이터를 *내주는 쪽* / *받아 쓰는 쪽* |
| **핸드셰이크** | handshake | 양쪽이 *각자 승인해야* 성립하는 절차 |
| **네임스페이스** | namespace | Redshift 클러스터·워크그룹의 *논리적 식별 단위* |
| **finding** | finding | Macie가 만드는 *탐지 결과 기록* |
| **관리형 식별자** | managed data identifier | AWS가 *내장 기준으로* 민감 유형을 탐지하는 규칙 |
| **데이터 상주** | data residency | 데이터를 *특정 관할권에 두어야 하는* 요건 |
| **데이터 주권** | data sovereignty | 데이터가 *물리적 위치의 법·규정 적용*을 받는 것 |
| **구성 항목** | configuration item | 어떤 시점의 *리소스 구성 스냅샷* |
| **aggregator** | aggregator | 여러 계정·리전의 Config 데이터를 *한 계정에서 모아 보는* 것 |
| **데이터 메시** | data mesh | 도메인별 생산자·소비자와 *중앙 거버넌스 계층*을 둔 구조 |

---

## 📖 핵심 개념

### 1) Redshift 데이터 공유와 권한 부여 {#redshift-sharing}

Redshift 데이터 공유는 ⚠️ **클러스터·워크그룹·AWS 계정·리전에 걸쳐 라이브 데이터를 수동 이동이나 복사 없이** 공유하는 기능입니다. 시험은 "복사 없이 최신 데이터를 다른 팀·계정이 쿼리"에서 이 기능을 고르게 하고, **교차 계정에서 누가 무엇을 승인하는지**를 묻습니다.

- **프로듀서 쪽 권한 부여** — 프로듀서 관리자가 datashare를 만들어 객체를 추가하고, 다른 DB 사용자에게 **datashare 변경(ALTER)·공유(SHARE) 권한을 위임**합니다. ⚠️ **위임은 클러스터 superuser와 datashare 소유자**가 할 수 있습니다. 소비자 추가는 **`GRANT USAGE ON DATASHARE`** 로 하며 ⚠️ **한 GRANT 문에는 소비자를 하나만** 쓸 수 있습니다.
- ⚠️ **교차 계정 = 양방향 핸드셰이크**
  1. 계정에 `GRANT USAGE` 를 하면 datashare 상태가 **`pending_authorization`** 이 됩니다.
  2. **프로듀서 계정 관리자가 소비자를 authorize** 합니다.
  3. **소비 계정 관리자가** 그 datashare를 **계정 전체 또는 특정 클러스터에 associate** 하거나 거부합니다.
  - ⚠️ **네임스페이스를 소비자로 추가할 때는 authorize가 필요 없습니다.**
  - ⚠️ **교차 계정 공유에서는 프로듀서·소비자 클러스터가 모두 암호화되어야** 합니다.
  - **같은 datashare를 계정 내 공유와 교차 계정 공유에 함께 쓸 수 있습니다**(별도로 만들 필요 없음).
- **쓰기 공유** — ⚠️ **이전에는 datashare 객체가 항상 읽기 전용이었으나 쓰기가 추가**됐습니다. **프로듀서가 INSERT·CREATE 같은 쓰기 권한을 datashare에 명시적으로 부여한 객체만** 쓰기가 가능하고, 교차 계정에서는 **프로듀서가 쓰기용으로 authorize하고 소비자가 특정 클러스터·워크그룹을 쓰기용으로 associate** 해야 합니다.
  - 📌 일부 공식 문서는 아직 "읽기 목적" 공유로만 서술합니다(문서 간 시차).
- **Lake Formation 관리 datashare** — Lake Formation 관리자가 Redshift datashare를 **발견·등록**하면 **DB·테이블·열·행 수준 접근 권한을 Lake Formation에서 중앙 정의·집행**합니다. **같은 계정·교차 계정 공유를 지원하고** ⚠️ **교차 리전 공유는 지원하지 않습니다.**
  - **제약** — ⚠️ **셀 수준 Lake Formation 필터 미지원**, **프로듀서·소비자 클러스터 모두 암호화 필요**, ⚠️ **프로듀서의 Redshift 행·열 수준 접근 제어 정책은 Lake Formation으로 공유할 때 무시되므로 Lake Formation에서 설정해야** 합니다.

| 방식 | 권한을 정하는 곳 | 교차 계정 | 교차 리전 | 특이점 |
|---|---|---|---|---|
| **Redshift 데이터 공유** | 프로듀서의 `GRANT USAGE`·SHARE 등 | 가능: **authorize + associate**, 양쪽 암호화 | **가능** | 쓰기는 **프로듀서가 쓰기 권한을 부여한 객체만** |
| **Lake Formation 관리 datashare** | **Lake Formation에서 DB·테이블·열·행 권한 중앙 정의** | 가능 | ⚠️ **미지원** | **셀 수준 필터 미지원**, Redshift 행·열 정책은 **무시** |

### 2) PII 식별 — Amazon Macie {#macie}

Macie는 S3 객체를 **내장 기준·기법(머신러닝, 패턴 매칭)으로 분석해 민감 데이터를 찾고 finding을 만드는** 서비스입니다. ⚠️ **"찾기"(Macie)와 "가리기·접근 통제"(Glue·Redshift DDM·Lake Formation)를 구분하는 것이 핵심**입니다.

- **두 가지 검색 방식**
  - **자동 민감 데이터 검색** — 버킷 인벤토리를 **지속 평가**하고 **표본으로 대표 객체를 골라 광범위한 가시성**을 줍니다.
  - **민감 데이터 검색 작업** — **대상 버킷·샘플링 깊이·사용자 정의 조건을 지정한 정밀 분석**이며 **1회성 또는 반복 실행**을 선택합니다.
- **식별자** — **관리형 데이터 식별자**는 PII·금융 정보·자격 증명 같은 유형을 **내장 기준으로** 탐지하고, **사용자 지정 데이터 식별자**는 **정규식(regex)** 을 기본으로 선택적 문자 시퀀스와 근접 규칙을 더해 직접 정의합니다.
- **결과 처리** — Macie는 정책 finding과 민감 데이터 finding을 **EventBridge로 자동 게시**하고, 설정하면 **AWS Security Hub CSPM** 으로도 게시합니다. EventBridge로 Lambda·SNS 등에 연결해 자동화할 수 있습니다.
- ⚠️ **암호화된 객체 — 이 표가 문항입니다.**

| S3 객체 암호화 | Macie 분석 가능 여부 |
|---|---|
| **SSE-S3** | ✅ 가능 |
| **AWS 관리형 KMS 키**(SSE-KMS/DSSE-KMS) | ✅ 가능(서비스 연결 역할로 복호화) |
| **고객 관리형 KMS 키** | ⚠️ **Macie에 키 사용을 허용했을 때만** 가능, 아니면 **메타데이터만** |
| **SSE-C** | ❌ **불가(메타데이터만)** |
| **클라이언트 측 암호화** | ❌ **불가(메타데이터만)** |

- **Lake Formation과의 결합(근거 범위 주의)** — 📌 **제품 문서에서 Macie–Lake Formation 직접 연동 설정은 확인되지 않았고, 근거는 AWS 보안 블로그의 참조 아키텍처**입니다. 흐름은 **Macie가 S3 객체를 분석해 민감 값을 식별 → EventBridge → Firehose → S3 → Glue 워크플로가 데이터를 익명화(마스킹·암호화) → Lake Formation이 설정한 태그에 권한을 매핑해 사용자별 세분화 접근 적용** 입니다.

### 3) 허용되지 않는 리전으로의 백업·복제 방지 {#region-control}

핵심은 ⚠️ **"리전 호출 자체를 막는 통제"와 "복제·복사 구성을 막는 통제"가 다르다**는 점입니다.

- **`aws:RequestedRegion` 조건 키** — 요청에서 **호출된 리전과 정책에 지정한 리전을 비교**하며 요청 가능한 리전을 제어하는 데 씁니다. ⚠️ **IAM 같은 일부 글로벌 서비스는 엔드포인트가 하나(us-east-1)** 라서 "요청 리전이 X가 아니면 모든 서비스 거부" 정책을 쓰면 **IAM 호출이 항상 실패**하므로 **`NotAction` 예외**가 필요합니다.
- ⚠️ **한계** — 이 조건 키는 **호출되는 엔드포인트를 통제할 뿐 작업의 영향은 통제하지 않습니다.** S3는 API 작업이 리전에 걸쳐 영향을 주며, **한 리전에서 호출한 `s3:PutBucketReplication` 이 복제 구성에 따라 다른 리전에 영향**을 줍니다.
- **Control Tower Region deny** — 랜딩존 전체에 적용하는 컨트롤(**AWS-GR_REGION_DENY**)과 특정 OU에 적용하는 컨트롤(**CT.MULTISERVICE.PV.1**) 두 가지가 있습니다. ⚠️ **홈 리전은 거부할 수 없고**, IAM·Organizations 같은 일부 글로벌 서비스는 **예외**이며, ⚠️ **적용 전에 거부 대상 리전에 리소스가 있으면 적용 후 접근할 수 없게 됩니다.**
- **S3 교차 리전 복제 금지** — Control Tower **선택적 예방 컨트롤(SCP 기반)** 이 S3 데이터를 **단일 리전에 가두기 위해 자동·비동기 객체 복사를 비활성화**합니다. ⚠️ **기본으로 꺼져 있습니다.**
- **AWS Backup 교차 리전 복사** — 백업을 **주문형 또는 백업 계획에 따라 여러 리전에 복사**할 수 있고, **복사본은 대상 볼트의 고객 관리형 키로 재암호화**됩니다. 📌 **허용되지 않는 리전으로의 복사를 막는 공식 통제 문구는 이번 조사에서 확인되지 않았습니다.**

| 수단 | 통제 대상 | 한계·주의 |
|---|---|---|
| **SCP/IAM `aws:RequestedRegion` Deny** | **호출 리전** 기준 서비스 호출 | 글로벌 서비스 **`NotAction` 예외 필요**, ⚠️ **S3 복제 구성의 다른 리전 영향은 통제 못함** |
| **Control Tower 랜딩존 Region deny** | 랜딩존에서 거버넌스 대상이 아닌 리전 접근 | ⚠️ **홈 리전 거부 불가**, 일부 글로벌 서비스 예외 |
| **Control Tower OU Region deny** | 지정한 **OU** 의 리전 접근 | 랜딩존 컨트롤과의 상호작용은 미확인 |
| **Control Tower S3 교차 리전 복제 금지** | **S3 교차 리전 복제 구성** | ⚠️ **선택적 컨트롤, 기본 꺼짐** |

### 4) 구성 변경 조회 — AWS Config {#aws-config}

> 📌 **v1.1 개정(Skill 4.5.4)** — "**Managing** configuration changes" → "**Viewing** configuration changes"(관리 → **조회**).

- **구성 이력·타임라인** — 구성 이력은 **한 리소스의 구성 항목들을 기간별로 모은 것**입니다. 콘솔에서 리소스를 골라 **타임라인으로 이전 구성 항목을 탐색**하고 API로도 조회합니다. Config는 **기록 대상 리소스 유형별 구성 이력 파일을 지정한 S3 버킷으로** 전달합니다.
- **보존 기간** — 콘솔에서 보존 기간을 고르지 않으면 **기본 7년(2557일)** 이고, 사용자 지정은 **30~2557일** 입니다.
- **aggregator** — 여러 소스 계정·리전(또는 조직)의 구성·컴플라이언스 데이터를 **한 계정으로 모아 보며 추가 비용이 없습니다.** ⚠️ **읽기 전용 뷰라서 집계자를 통해 규칙을 배포하거나 스냅샷 파일을 소스 계정에 푸시할 수 없습니다.**
- **고급 쿼리 vs 과거 이력** — 고급 쿼리는 중앙 계정에서 **리소스의 현재 구성 상태**를 쿼리하며 계정·리전·조직에 걸쳐 동작합니다. ⚠️ **현재 상태 데이터만 조회하므로 과거 이력은 Athena로 Config history files를 조회**합니다.
- **CloudTrail과의 관계** — Config는 CloudTrail과 통합해 **구성 변경을 특정 이벤트에 상관**시킵니다. ⚠️ **요청자·시각·IP 같은 호출 세부 정보는 CloudTrail 로그에서** 얻습니다.

| 알고 싶은 것 | 도구 |
|---|---|
| 리소스의 **과거 구성·변경 타임라인** | **AWS Config 구성 이력** |
| 변경을 일으킨 **API 호출 주체·시각·IP** | **CloudTrail 로그**(Config 타임라인과 연계) |
| 여러 계정·리전의 **현재 구성/컴플라이언스를 한곳에서** | **Config aggregator(읽기 전용)** |
| **현재** 구성 상태를 쿼리로 조회 | **Config 고급 쿼리** |
| **과거** 구성 상태를 쿼리로 조회 | **Athena + Config history files** |

### 5) 데이터 주권 유지 {#data-sovereignty}

> 📌 **v1.1 개정(Skill 4.5.5)** — Knowledge "Data sovereignty" → Skill "**Maintain** data sovereignty".

- ⚠️ **용어 구분** — **데이터 상주(residency)** 는 **데이터를 특정 관할권에 두어야 하는 요건**이고, **데이터 주권(sovereignty)** 은 **데이터가 물리적 위치의 법과 규정의 적용을 받는 것**입니다.
- **AWS의 기본 약속** — 고객이 콘텐츠를 저장할 **AWS 리전을 선택**하고, AWS는 **서비스 제공이나 법적 의무 같은 예외를 제외하고 선택한 리전 밖으로 콘텐츠를 이동·복제하지 않습니다.** ⚠️ **여러 리전에 복제·백업하는 것은 고객의 선택**입니다.
- **S3의 리전 격리** — 리전에 저장된 객체는 ⚠️ **명시적으로 전송·복제하지 않는 한 그 리전을 떠나지 않습니다.**
- **실행 수단** — 주권·상주 요건은 **① 저장 리전을 선택하고 ② 데이터가 리전 밖으로 나가는 경로를 통제**하는 것으로 구현합니다 — **Region deny, S3 교차 리전 복제 금지, 백업 복사 대상 관리**. (암호화 키 제어는 `dea-t4-3` 참조)

### 6) SageMaker Catalog 프로젝트를 통한 데이터 접근 관리 {#sagemaker-catalog}

> 📌 **v1.1 신규 Skill(4.5.6)** 입니다. 도메인·도메인 단위·프로젝트 구조는 **`dea-t4-1`** 을 참조하고, 여기서는 **접근 요청 → 승인 → 이행**에 집중합니다.

- **구독 승인** — 소비 프로젝트가 카탈로그의 자산을 구독하면 **구독 요청**이 생기고 승인자가 승인하거나 거부합니다. ⚠️ **승인자는 소유(게시) 프로젝트의 멤버여야** 하고, ⚠️ **기본값은 데이터 소유자의 수동 승인**입니다. 승인할 때 **전체 접근 또는 행·열 필터를 적용한 제한 접근**을 고를 수 있습니다.
- **자동 승인** — **게시할 때 승인을 요구하지 않도록 설정했거나**, 요청자가 **게시 프로젝트와 요청 프로젝트 양쪽의 owner 또는 contributor** 인 경우 자동 승인됩니다.
- **이행(fulfillment)** — 승인 후 접근을 실제로 만드는 방식은 **자산 유형에 따라 다릅니다.**
  - **Lake Formation 관리 Glue 테이블** — 승인되면 SageMaker Unified Studio가 **Lake Formation을 통해 승인된 테이블에 대한 접근을 부여·관리**합니다. ⚠️ **Glue 테이블은 Lake Formation 관리 상태여야** 하고 **게시 프로젝트의 IAM 역할에 해당 DB·테이블 DESCRIBE·SELECT(GRANTABLE 포함) 권한**이 있어야 합니다. ⚠️ **Lake Formation LF-TBAC 방식의 접근 관리는 지원하지 않습니다.**
  - **Redshift 테이블·뷰** — 승인되면 **필요한 grant와 datashare를 만듭니다.** 같은 DB면 **원본 테이블에 직접 권한**, 같은 클러스터의 다른 DB면 **대상 DB에 뷰를 만들어 뷰에 권한**, 같은 계정의 다른 클러스터면 **datashare와 뷰**, 교차 계정이면 **프로듀서 authorize와 소비자 associate 단계가 추가**됩니다. ⚠️ **교차 리전 Redshift 데이터 공유는 지원하지 않습니다.**

| 자산 유형 | 이행 방식 | 제약 |
|---|---|---|
| **Lake Formation 관리 Glue 테이블** | Lake Formation 권한 부여·관리 | ⚠️ **LF-TBAC 방식 관리 미지원** |
| **Redshift 테이블·뷰** | **grant + datashare(+뷰)** 생성 | 교차 계정은 **authorize·associate 추가**, ⚠️ **교차 리전 미지원** |

### 7) 거버넌스 데이터 프레임워크와 공유 패턴 {#governance-patterns}

> 📌 **v1.1 신규 Skill(4.5.7)** 입니다.

- **데이터 메시 참조 구조** — **소비자·생산자·중앙 거버넌스 계층은 각각 독립된 데이터 도메인**이며 ⚠️ **보통 별도 AWS 계정**에 둡니다. **연합 거버넌스 계층**은 **카탈로깅, 자산 검색, 권한 관리, 감사 이력용 중앙 로그**를 맡는 중앙 거버넌스 도메인입니다.
- **Lake Formation 교차 계정 공유** — 다른 계정과 DB·테이블을 공유하는 방법은 **① 이름 지정 리소스 방식**과 **② LF-TBAC(태그 기반)** 두 가지입니다. 이름 지정 리소스 방식은 **외부 계정에 권한을 줄 때 AWS RAM으로 리소스를 공유**합니다. ⚠️ **대상 Data Catalog 객체가 많을 때는 LF-TBAC가 권장**되며 **LF-Tag는 IAM 태그와 다릅니다.**
- **Redshift 데이터 공유** — Redshift 간 **라이브 공유**(위 1절), 열·행 수준 중앙 통제가 필요하면 **Lake Formation 관리 datashare**.
- **S3 Access Points** — 버킷에 붙는 **이름 있는 네트워크 엔드포인트**로, 공유 데이터셋에 대해 **앱·팀별로 서로 다른 권한과 네트워크 제어**를 줄 때 씁니다. **버킷당 최대 10,000개**이며 같은 계정 또는 **신뢰된 다른 계정의 버킷**과 연결할 수 있고, **접근점 정책은 기반 버킷 정책과 함께 평가**됩니다.
- **AWS Data Exchange for Amazon Redshift** — **제3자 데이터를 구독해 Redshift에서 바로 쿼리**하며, ⚠️ **구독하면 접근이 자동 부여되고 구독이 끝나면 자동 회수**됩니다.

| 수단 | 적합한 경우 | 제약·특이점 | 시험 단서 |
|---|---|---|---|
| **Redshift 데이터 공유** | 웨어하우스 간 **복사 없는 라이브 공유** | 교차 계정은 **authorize+associate**, 양쪽 암호화 | "클러스터 간·계정 간 최신 데이터" |
| **Lake Formation 교차 계정 공유** | 데이터 레이크 Data Catalog 테이블을 다른 계정과 | **이름 지정(RAM) vs LF-TBAC(권장)** | "열·행 수준 중앙 통제, 다계정 레이크" |
| **Lake Formation 관리 datashare** | Redshift 객체에도 LF 열·행 권한 적용 | ⚠️ **교차 리전·셀 수준 필터 미지원** | "Redshift 공유 + LF 중앙 권한" |
| **S3 Access Points** | 공유 S3 데이터셋에 **앱별 접근 정책 분리** | **버킷당 10,000개**, 버킷 정책과 함께 평가 | "수많은 앱이 같은 버킷" |
| **AWS Data Exchange** | **제3자 데이터 라이선스 구독** | **구독 종료 시 접근 자동 회수** | "외부 공급자 데이터 구독" |

---

## ✍️ 시험 포인트

1. **"복사·ETL 없이 다른 클러스터/계정이 최신 데이터를 쿼리"** → **Redshift 데이터 공유**. 스냅샷 복원·UNLOAD/COPY는 **데이터를 복사하는 방식**이라 오답입니다.
2. **교차 계정 절차를 순서로** — `GRANT USAGE`(→ `pending_authorization`) → **프로듀서 계정 관리자 authorize** → **소비 계정 관리자 associate**, 그리고 **양쪽 클러스터 암호화**. ⚠️ **네임스페이스 소비자는 authorize 불필요**입니다.
3. **"Redshift 공유 객체에도 열·행 단위를 중앙에서 통제"** → **Lake Formation 관리 datashare**(⚠️ **교차 리전·셀 수준 필터 미지원**, Redshift 자체 행·열 정책은 **무시**).
4. **"소비자가 프로듀서 테이블에 INSERT"** → **쓰기 공유**이며 **프로듀서가 쓰기 권한을 명시적으로 부여한 객체만** 가능합니다.
5. **"S3 어디에 PII가 있는지 찾기"** → **Macie**. **"가리기"** 는 Glue·DataBrew·DDM, **"접근 통제"** 는 Lake Formation입니다.
6. **"검색 작업이 일부 객체를 건너뜀"** → **SSE-C·클라이언트 측 암호화는 복호화 불가(메타데이터만)**, **고객 관리형 KMS 키는 Macie에 키 사용을 허용해야** 합니다.
7. **"전체 가시성" vs "특정 버킷 정밀"** → **자동 민감 데이터 검색** vs **민감 데이터 검색 작업**.
8. **"허용 리전 밖으로 복제·백업 금지"** → **Region deny** 로 비허용 리전 호출을 막고, ⚠️ **S3 교차 리전 복제는 `aws:RequestedRegion` 만으로 막히지 않으므로 복제 구성을 막는 컨트롤**(Control Tower의 S3 교차 리전 복제 금지)을 **추가**합니다.
9. **"모든 리전 Deny 후 IAM 호출이 항상 실패"** → **글로벌 서비스 `NotAction` 예외**가 빠졌습니다. Control Tower Region deny도 **홈 리전은 거부 불가**입니다.
10. **"어제 리소스 구성이 시점별로 어떻게 바뀌었나"** → **Config 구성 이력·타임라인**. **"누가 호출했나"** → **CloudTrail**.
11. **"지난달 구성 상태를 쿼리"** → ⚠️ **고급 쿼리는 현재 상태만**이므로 **Athena + Config history files** 입니다.
12. **"중앙 계정에서 모든 계정에 규칙 배포"** → **aggregator는 읽기 전용**이라 불가합니다.
13. **"SageMaker Catalog 구독을 누가 승인하나"** → **소유(게시) 프로젝트 멤버**, 기본 **수동 승인**.

---

## ⚠️ 흔한 함정

1. **데이터 공유를 "복사해 두는 것"으로 생각** — ⚠️ **수동 이동·복사 없이 라이브 데이터**를 공유합니다.
2. **한 GRANT 문에 소비자를 여러 개 지정** — ⚠️ **하나만** 쓸 수 있습니다.
3. **일반 DB 사용자가 datashare 권한을 위임할 수 있다고 생각** — **클러스터 superuser와 datashare 소유자**만 가능합니다.
4. **`GRANT USAGE` 만으로 교차 계정 공유가 완료된다고 생각** — ⚠️ **`pending_authorization`** 상태이며 **프로듀서 authorize + 소비자 associate** 가 남았습니다.
5. **네임스페이스 소비자에게도 authorize가 필요하다고 생각** — ⚠️ **필요 없습니다.**
6. **교차 계정 공유에 암호화가 필요 없다고 생각** — ⚠️ **프로듀서·소비자 클러스터 모두 암호화**되어야 합니다.
7. **계정 내 공유와 교차 계정 공유에 datashare를 따로 만들려 함** — **같은 datashare를 함께 쓸 수 있습니다.**
8. **"datashare는 항상 읽기 전용"으로 외움** — **쓰기가 추가**됐습니다(프로듀서가 명시적으로 부여한 객체만).
9. **Lake Formation 관리 datashare로 교차 리전 공유를 기대** — ⚠️ **미지원**입니다.
10. **Lake Formation 관리 datashare에서 셀 수준 필터를 기대** — ⚠️ **미지원**입니다.
11. **프로듀서의 Redshift 행·열 정책이 그대로 적용된다고 생각** — ⚠️ **Lake Formation으로 공유할 때 무시**되므로 Lake Formation에서 설정해야 합니다.
12. **Macie로 마스킹·접근 통제를 기대** — Macie는 **탐지·finding 생성**이며 EventBridge·Security Hub CSPM으로 게시합니다.
13. **Macie가 모든 암호화 객체를 분석한다고 생각** — **SSE-C·클라이언트 측은 불가(메타데이터만)**, **고객 관리형 KMS는 키 사용 허용 필요**입니다.
14. **사용자 지정 데이터 식별자를 내장 규칙으로 생각** — **정규식 기반으로 직접 정의**합니다(내장은 관리형 식별자).
15. **Macie–Lake Formation 직접 연동이 제품 기능이라고 단정** — 📌 **근거는 참조 아키텍처(블로그)** 이며 제품 문서의 연동 설정은 확인되지 않았습니다.
16. **`aws:RequestedRegion` 하나로 CRR까지 차단된다고 가정** — ⚠️ **호출 엔드포인트만 통제**하고 **복제 구성의 다른 리전 영향은 통제하지 않습니다.**
17. **글로벌 서비스 예외를 빼고 전체 Deny** — IAM은 **단일 엔드포인트(us-east-1)** 라 **호출이 항상 실패**합니다.
18. **Control Tower Region deny로 홈 리전까지 막으려 함** — ⚠️ **거부할 수 없습니다.**
19. **Region deny를 켜기 전 기존 리소스를 확인하지 않음** — ⚠️ **거부 대상 리전의 리소스에 접근할 수 없게 됩니다.**
20. **S3 교차 리전 복제 금지 컨트롤이 기본 켜져 있다고 생각** — ⚠️ **선택적 컨트롤이며 기본 꺼짐**입니다.
21. **암호화(KMS)나 Config 조회를 리전 차단 수단으로 선택** — 차단은 **SCP·Control Tower 컨트롤**의 영역입니다.
22. **데이터 상주와 데이터 주권을 같은 말로 생각** — **상주는 위치 요건**, **주권은 그 위치의 법·규정 적용**입니다.
23. **AWS가 리전 밖으로 데이터를 옮긴다고 생각** — **서비스 제공·법적 의무 예외를 빼면 옮기지 않으며**, 다중 리전 복제는 **고객의 선택**입니다.
24. **Config 고급 쿼리로 과거 이력을 조회** — ⚠️ **현재 상태만**이며 과거는 **Athena + history files** 입니다.
25. **aggregator로 규칙을 배포하려 함** — ⚠️ **읽기 전용 뷰**입니다.
26. **Config로 "누가 바꿨나"를 알려고 함** — **요청자·시각·IP는 CloudTrail** 에서 얻습니다.
27. **Config 보존 기간 기본값을 짧게 가정** — **기본 7년(2557일)**, 사용자 지정 **30~2557일** 입니다.
28. **구독 승인자를 소비 프로젝트 멤버로 생각** — ⚠️ **소유(게시) 프로젝트의 멤버**입니다.
29. **구독이 기본 자동 승인이라고 생각** — ⚠️ **기본은 데이터 소유자의 수동 승인**입니다.
30. **SageMaker Catalog 이행에 LF-TBAC를 쓰려 함** — ⚠️ **미지원**입니다.
31. **SageMaker Catalog에서 교차 리전 Redshift 공유를 기대** — ⚠️ **미지원**입니다.
32. **S3 Access Points를 Redshift 테이블 공유 수단으로 오해** — Access Points는 **S3 데이터셋**용입니다.
33. **Data Exchange를 조직 내부 공유 수단으로 생각** — **제3자 데이터 구독·라이선스**이며 내부 공유는 Redshift 데이터 공유·Lake Formation입니다.

---

## 🧪 자가 점검

**Q1.** 다른 AWS 계정의 분석 팀이 우리 Redshift 데이터를 복사 없이 최신 상태로 쿼리해야 한다. 어떤 순서로 설정하며 무엇을 함께 확인하는가?

<details><summary>정답 보기</summary>

**Redshift 데이터 공유를 사용합니다.** 프로듀서 관리자가 datashare를 만들어 객체를 추가하고 **`GRANT USAGE ON DATASHARE` 로 소비 계정을 추가**하면 상태가 **`pending_authorization`** 이 됩니다. 그다음 ⚠️ **프로듀서 계정 관리자가 소비자를 authorize** 하고, **소비 계정 관리자가 계정 전체 또는 특정 클러스터에 associate** 합니다(**양방향 핸드셰이크**). 함께 확인할 것은 ⚠️ **프로듀서·소비자 클러스터가 모두 암호화**되어야 한다는 점이고, 한 GRANT 문에는 **소비자를 하나만** 씁니다. 스냅샷 복원·UNLOAD/COPY는 **데이터를 복사하는 방식**이라 요구에 맞지 않습니다.
</details>

**Q2.** S3 데이터 레이크에서 PII가 어디 있는지 찾아 이후 열 단위 접근을 통제하려 한다. 공식 근거로 설명할 수 있는 흐름은?

<details><summary>정답 보기</summary>

**Macie로 탐지(자동 민감 데이터 검색 또는 민감 데이터 검색 작업) → finding을 EventBridge로 전달 → Glue 워크플로가 마스킹·암호화 → Lake Formation이 태그에 권한을 매핑해 사용자별 세분화 접근을 적용**합니다. ⚠️ **Macie 단독으로는 마스킹·접근 통제를 하지 않습니다**(탐지·finding 생성). 또 ⚠️ **SSE-C·클라이언트 측 암호화 객체는 복호화할 수 없어 메타데이터만 보고**되고, **고객 관리형 KMS 키 객체는 Macie에 키 사용을 허용해야** 분석됩니다. 📌 Macie–Lake Formation 결합의 근거는 **참조 아키텍처(AWS 보안 블로그)** 입니다.
</details>

**Q3.** 규제 때문에 데이터가 허용된 리전 밖으로 복제·백업되면 안 된다. SCP에 `aws:RequestedRegion` Deny를 적용했는데도 S3 교차 리전 복제가 설정될 수 있었다. 무엇을 추가해야 하는가?

<details><summary>정답 보기</summary>

**복제 구성 자체를 막는 컨트롤(Control Tower의 S3 교차 리전 복제 금지 선택적 예방 컨트롤)을 추가합니다.** ⚠️ **`aws:RequestedRegion` 은 호출되는 엔드포인트만 통제하고 작업의 영향은 통제하지 않습니다** — S3는 API 작업이 리전에 걸쳐 영향을 주며, **허용 리전에서 호출한 `s3:PutBucketReplication` 이 다른 리전에 영향**을 줍니다. 이 컨트롤은 **기본으로 꺼져 있습니다.** 또 전체 Deny 정책에는 **IAM 같은 글로벌 서비스의 `NotAction` 예외**가 필요하고, Control Tower Region deny는 **홈 리전을 거부할 수 없습니다.**
</details>

**Q4.** 어떤 리소스의 구성이 어제 시점별로 어떻게 바뀌었는지, 그리고 누가 그 변경을 호출했는지 알아야 한다. 각각 무엇을 쓰는가?

<details><summary>정답 보기</summary>

**구성 변화는 AWS Config 구성 이력·타임라인으로 보고, 변경을 일으킨 요청자·시각·IP는 CloudTrail 로그에서 얻습니다**(Config는 CloudTrail과 통합해 변경을 특정 이벤트에 상관시킵니다). ⚠️ **Config 고급 쿼리는 현재 구성 상태만** 조회하므로 과거 상태는 **Athena로 Config history files** 를 조회하고, ⚠️ **aggregator는 읽기 전용 뷰**라서 규칙 배포·스냅샷 푸시를 할 수 없습니다. 보존 기간은 지정하지 않으면 **기본 7년(2557일)** 입니다.
</details>

**Q5.** SageMaker Catalog에서 소비 프로젝트가 게시된 Glue 테이블을 구독했다. 승인은 누가 하고, 승인 후 접근은 어떻게 만들어지는가?

<details><summary>정답 보기</summary>

**승인자는 소유(게시) 프로젝트의 멤버이며 기본값은 데이터 소유자의 수동 승인**입니다(게시 시 승인을 요구하지 않도록 했거나 요청자가 양쪽 프로젝트의 owner/contributor면 자동 승인). 승인 시 **전체 접근 또는 행·열 필터를 적용한 제한 접근**을 고를 수 있습니다. 이행은 자산 유형에 따라 다르며, **Lake Formation 관리 Glue 테이블은 SageMaker Unified Studio가 Lake Formation을 통해 접근을 부여·관리**합니다(⚠️ **테이블이 Lake Formation 관리 상태여야 하고 LF-TBAC 방식 관리는 미지원**). **Redshift 자산은 grant와 datashare(+뷰)** 를 만들며 ⚠️ **교차 리전 공유는 미지원**입니다.
</details>

---

**Q6 (원리).** 왜 "리전 밖으로 나가지 못하게" 하는 통제는 한 가지 수단으로 끝나지 않을까요?

<details><summary>정답 보기</summary>

**데이터가 리전을 떠나는 경로가 "호출"과 "구성" 두 가지로 나뉘기 때문입니다.** `aws:RequestedRegion` 류의 통제는 **"어느 리전의 엔드포인트에 요청을 보냈는가"** 를 봅니다. 그런데 S3 복제나 백업 복사는 **허용된 리전에서 설정 한 번을 호출하면, 그 뒤로는 데이터가 서비스 내부에서 다른 리전으로 계속 흘러갑니다.** 호출은 허용 리전에서 일어났으니 조건 키로는 걸리지 않습니다. 그래서 공식 문서가 "이 조건 키는 **호출되는 엔드포인트를 통제할 뿐 작업의 영향은 통제하지 않는다**"고 명시하고, 복제를 막으려면 **`s3:PutReplicationConfiguration` 같은 구성 작업 자체를 막는 별도 컨트롤**을 둡니다. 데이터 주권 요건을 설계할 때 **"리전을 고르는 것"(①)과 "밖으로 나가는 경로를 막는 것"(②)** 을 따로 적어 두면, 어떤 수단이 ①이고 어떤 수단이 ②인지 섞이지 않습니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-17 · 보강: 2026-10-19 · 저작: 2026-10-20 · 사람 검수 전)

1. Considerations for data sharing in Amazon Redshift — https://docs.aws.amazon.com/redshift/latest/dg/datashare-considerations.html
2. Sharing data across AWS accounts (Amazon Redshift Database Developer Guide) — https://docs.aws.amazon.com/redshift/latest/dg/across-account.html
3. Producer administrator actions (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/producer-cluster-admin.html
4. AWS Lake Formation-managed datashares (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/lf_datashare_overview.html
5. Considerations for data sharing with AWS Lake Formation in Amazon Redshift — https://docs.aws.amazon.com/redshift/latest/dg/lake-formation-considerations.html
6. What is Amazon Macie? — https://docs.aws.amazon.com/macie/latest/user/what-is-macie.html
7. Monitoring and processing Macie findings — https://docs.aws.amazon.com/macie/latest/user/findings-monitor.html
8. Analyzing encrypted Amazon S3 objects (Amazon Macie) — https://docs.aws.amazon.com/macie/latest/user/discovery-supported-encryption-types.html
9. Data masking and granular access control using Amazon Macie and AWS Lake Formation (AWS Security Blog) — https://aws.amazon.com/blogs/security/data-masking-and-granular-access-control-using-amazon-macie-and-aws-lake-formation/
10. AWS global condition context keys (IAM User Guide; `aws:RequestedRegion`) — https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_condition-keys.html
11. Configure the Region deny control (AWS Control Tower User Guide) — https://docs.aws.amazon.com/controltower/latest/userguide/region-deny.html
12. Elective controls with preventive behavior (AWS Control Tower controls reference) — https://docs.aws.amazon.com/controltower/latest/controlreference/elective-preventive-controls.html
13. Creating backup copies across AWS Regions (AWS Backup) — https://docs.aws.amazon.com/aws-backup/latest/devguide/cross-region-backup.html
14. AWS Config terminology and concepts — https://docs.aws.amazon.com/config/latest/developerguide/config-concepts.html
15. Deleting AWS Config Data (data retention period) — https://docs.aws.amazon.com/config/latest/developerguide/delete-config-data-with-retention-period.html
16. AWS Config best practices (AWS Cloud Operations Blog) — https://aws.amazon.com/blogs/mt/aws-config-best-practices/
17. AWS Service Integrations with AWS Config — https://docs.aws.amazon.com/config/latest/developerguide/service-integrations.html
18. AWS Data Privacy FAQ — https://aws.amazon.com/compliance/data-privacy-faq/
19. Definitions (AWS Well-Architected Digital Sovereignty Lens) — https://docs.aws.amazon.com/wellarchitected/latest/digital-sovereignty-lens/definitions.html
20. What is Amazon S3? (Regions) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html
21. Approve or reject a subscription request in Amazon SageMaker Unified Studio — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/approve-reject-subscription-request.html
22. Grant access to managed AWS Glue Data Catalog assets in Amazon SageMaker Unified Studio — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/grant-access-to-glue-asset.html
23. Grant access to managed Amazon Redshift assets in Amazon SageMaker Unified Studio — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/grant-access-to-redshift-asset.html
24. Reference architecture (data mesh; AWS Well-Architected Data Analytics Lens) — https://docs.aws.amazon.com/wellarchitected/latest/analytics-lens/data-mesh-reference-architecture.html
25. Lake Formation tag-based access control — https://docs.aws.amazon.com/lake-formation/latest/dg/tag-based-access-control.html
26. Sharing a data lake using Lake Formation tag-based access control and named resources — https://docs.aws.amazon.com/lake-formation/latest/dg/share-dl-tbac-tutorial.html
27. Access control in Amazon S3 (Access Points) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-management.html
28. AWS Data Exchange for Amazon Redshift — https://aws.amazon.com/data-exchange/why-aws-data-exchange/redshift-data-tables/
