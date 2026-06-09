---
examGuideTaskId: soa-t5-3
certCode: SOA-C03
domain: 5
domainName: 네트워킹 및 콘텐츠 전송
domainWeightPct: 18
title: Route 53 DNS·CloudFront 콘텐츠 전송
coversTasks:
  - "5.2"
sources:
  - title: Amazon Route 53 개발자 가이드 — 소개 (공식)
    url: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html
  - title: Route 53 라우팅 정책 선택 (공식)
    url: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html
  - title: Alias 레코드와 비-Alias 레코드 비교 (공식)
    url: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html
  - title: Amazon CloudFront 개발자 가이드 — 소개 (공식)
    url: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html
  - title: CloudFront 캐시 무효화 (공식)
    url: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Invalidation.html
  - title: S3 정적 웹사이트 호스팅 (공식)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html
lastVerified: 2026-06-09
---

# Route 53 DNS·CloudFront 콘텐츠 전송

> **커버하는 공식 Task** — SOA-C03 · 도메인 5 「네트워킹 및 콘텐츠 전송」(18%) · **Task 5.2 도메인, DNS 서비스 및 콘텐츠 전송 구성** (`soa-t5-3`)
> 이 문서는 Route 53 DNS와 CloudFront CDN, S3 정적 호스팅의 구성·운영에 집중합니다. 네트워크 문제 해결은 `soa-t5-4`에서 다룹니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명하고, 콘솔/CLI에서 직접 구성·운영할 수 있어야 합니다.

- [ ] **호스팅 영역** — 퍼블릭 vs 프라이빗 호스팅 영역의 차이를 안다
- [ ] **레코드 타입** — A / AAAA / CNAME / Alias 의 용도를 구분한다
- [ ] **Alias vs CNAME** — Zone Apex 가능 여부·비용·대상 차이를 설명할 수 있다
- [ ] **라우팅 정책 7종** — Simple/Weighted/Latency/Failover/Geolocation/Geoproximity/Multivalue 를 시나리오에 매핑한다
- [ ] **상태 확인 + Failover** — 헬스 체크와 라우팅 정책 연계를 구성할 수 있다
- [ ] **CloudFront 동작** — 엣지 로케이션·오리진·캐시 동작·TTL·무효화를 설명할 수 있다
- [ ] **OAC** — S3를 비공개로 유지하며 CloudFront만 접근하게 구성할 수 있다
- [ ] **HTTPS/ACM** — CloudFront용 인증서는 us-east-1, 지역 제한 구성을 안다
- [ ] **운영** — 도메인을 ALB/CloudFront에 Alias로 연결하고 캐시 무효화를 운영할 수 있다

---

## 🎯 왜 중요한가

- 도메인 5의 Task 5.2는 "도메인을 어디로 연결하고, 콘텐츠를 어떻게 빠르게 전달하느냐"를 다룹니다. 운영자는 **도메인-ALB/CloudFront 연결(Alias)**, **캐시 무효화**, **인증서 배치**를 실제로 구성합니다.
- **Alias vs CNAME**(Zone Apex 제약), **라우팅 정책 7종**, **CloudFront ACM은 us-east-1** 은 SOA·SAA 공통 단골 함정입니다.
- 운영 관점에서 "콘텐츠를 갱신했는데 사용자에게 옛 버전이 보인다"는 **캐시 TTL/무효화** 문제, "S3를 직접 접근 못 하게 막아라"는 **OAC** 문제가 절차형으로 출제됩니다.

---

## 📖 핵심 개념

### 1) Route 53 — 관리형 DNS와 호스팅 영역

> 공식 정의: **"고가용성·확장성 DNS 웹 서비스."** 도메인 등록·DNS 라우팅·상태 확인을 제공합니다. Route 53은 **글로벌 서비스**(리전 없음)입니다.

| 호스팅 영역 | 용도 |
|---|---|
| **퍼블릭 호스팅 영역** | 인터넷에 공개된 도메인의 DNS를 관리(누구나 조회 가능) |
| **프라이빗 호스팅 영역** | **특정 VPC 내부에서만** 해석되는 도메인. 내부 서비스 이름 해석에 사용 |

> 프라이빗 호스팅 영역이 동작하려면 연결된 VPC의 **enableDnsSupport / enableDnsHostnames** 가 켜져 있어야 합니다.

### 2) 레코드 타입 — A / AAAA / CNAME / Alias

| 타입 | 의미 |
|---|---|
| **A** | 도메인 → **IPv4 주소** |
| **AAAA** | 도메인 → **IPv6 주소** |
| **CNAME** | 도메인 → **다른 도메인 이름**(별칭). **Zone Apex 불가** |
| **Alias** | Route 53 전용 확장. 도메인 → **AWS 리소스**(ALB·CloudFront·S3 웹사이트·API GW 등) |

### 3) Alias vs CNAME (★ 단골 출제)

| 항목 | **Alias 레코드** | **CNAME 레코드** |
|---|---|---|
| 대상 | AWS 리소스(ALB·CloudFront·S3·API GW 등) | 임의의 도메인 |
| **Zone Apex**(example.com) | **가능** | **불가**(DNS 표준 제약) |
| 쿼리 비용 | **무료** | 일반 과금 |
| IP 자동 추적 | AWS 리소스 IP 변경 자동 반영 | 직접 관리 |

> **운영 핵심:** 루트 도메인(`example.com`)을 ALB나 CloudFront로 보내야 할 때는 **반드시 Alias** 입니다. CNAME은 Zone Apex에 쓸 수 없습니다. 서브도메인(`www.example.com`)은 CNAME도 가능하지만, AWS 리소스 대상이라면 Alias가 비용·관리 면에서 유리합니다.

### 4) 라우팅 정책 7종 (★ 핵심 비교)

| 정책 | 동작 원리 | 대표 용도 |
|---|---|---|
| **Simple(단순)** | 단일 레코드 반환 | 단일 리소스 기본 구성 |
| **Weighted(가중)** | 가중치(0~255) 비율로 분배 | A/B 테스트, 카나리 점진 배포 |
| **Latency(지연시간)** | **네트워크 지연이 가장 낮은** 리전으로 | 글로벌 성능 최적화 |
| **Failover(장애조치)** | 헬스 체크 기반 Primary → Secondary 자동 전환 | DR, 액티브-패시브 |
| **Geolocation(지리위치)** | **사용자의 지리적 위치(국가·대륙)** 기준 | 콘텐츠 현지화, 지역 규제 |
| **Geoproximity(지리근접)** | 리소스 위치 + **bias** 로 트래픽 범위 조정 | 트래픽 점진 이동(Traffic Flow 필요) |
| **Multivalue(다중값)** | 최대 8개 정상 레코드 무작위 반환 + 헬스 체크 | 단순 부하 분산(LB 대체 아님) |

> **Latency vs Geolocation:** Latency는 **측정된 네트워크 지연**으로, Geolocation은 **사용자 IP의 지리적 위치**로 결정합니다. "가장 빠른 응답"은 Latency, "국가별 콘텐츠/규제"는 Geolocation.
> **Geoproximity**는 **Route 53 Traffic Flow** 에서만 사용하며 bias 값으로 트래픽 비중을 조정합니다.

### 5) 상태 확인(Health Check) + Failover

- **엔드포인트 상태 확인:** HTTP/HTTPS/TCP로 엔드포인트를 주기적으로 점검.
- **계산형 상태 확인:** 여러 하위 체크를 AND/OR 조합.
- **CloudWatch 경보 기반:** 경보 상태를 상태 확인 결과로 사용.

헬스 체크와 연동되는 정책: **Failover**(Primary 실패 시 Secondary), **Multivalue**(비정상 레코드 제외), Weighted/Latency/Geolocation(실패 레코드 응답 제외).

### 6) CloudFront — 글로벌 CDN

> 공식 정의: **"정적·동적 콘텐츠를 전 세계 사용자에게 빠르게 배포하는 웹 서비스."** 엣지 로케이션에 콘텐츠를 캐싱해 지연과 오리진 부하를 줄입니다.

| 요소 | 설명 |
|---|---|
| **Origin(오리진)** | 원본 — **S3 버킷, ALB, EC2, 임의 HTTP 서버(custom)** |
| **Edge Location(엣지 로케이션)** | 전 세계 캐싱·전송 지점. 리전 수보다 훨씬 많음 |
| **Distribution(배포)** | CloudFront 구성 단위(오리진·캐시 동작·도메인 묶음) |
| **Cache Behavior(캐시 동작)** | **경로 패턴별** 캐시 정책, TTL, 헤더/쿠키/쿼리 전달, 압축 |
| **OAC**(Origin Access Control) | S3를 CloudFront 경유로만 접근 허용(OAI 후속·현 권장) |

**캐시·TTL·무효화(운영 핵심):**

- **TTL**: 엣지가 객체를 캐시하는 시간. Cache-Control/Expires 헤더 또는 캐시 정책의 Min/Default/Max TTL로 제어.
- **무효화(Invalidation)**: 콘텐츠를 즉시 갱신해야 할 때 `/*` 또는 특정 경로를 무효화해 엣지 캐시를 제거. **소수 경로 무효화는 비용이 적지만, 잦은 전체 무효화는 비용·부하**가 큽니다.
- **버전 문자열 권장:** 무효화 남발 대신 파일명/쿼리에 버전(`app.v2.js`)을 넣어 새 객체로 취급하게 하는 운영 패턴이 권장됩니다.

```
# 특정 경로 캐시 무효화 (AWS CLI)
aws cloudfront create-invalidation \
  --distribution-id E123ABC456DEF \
  --paths "/index.html" "/css/*"
```

**S3 오리진 보호(OAC):**

```
사용자 → CloudFront Edge → (OAC) → S3 버킷 (Block Public Access ON)
사용자가 S3 URL 직접 접근 → 403 차단
```

> OAC를 쓰면 S3 버킷 정책에 **CloudFront 서비스 주체만 허용**하는 조건을 넣고 **퍼블릭 액세스 차단(Block Public Access)** 을 켭니다. 사용자는 CloudFront 도메인으로만 접근합니다.

**HTTPS·인증서·지역 제한:**

- **ACM 인증서는 반드시 `us-east-1`(버지니아 북부)** 에서 발급해야 CloudFront에 연결할 수 있습니다.
- **지역 제한(Geo Restriction)**: 특정 국가의 접근을 허용/차단.
- **WAF 연동**: SQL Injection·XSS 등 방어.

### 7) S3 정적 웹사이트 호스팅

- S3 버킷의 **정적 웹사이트 호스팅**을 켜면 인덱스/오류 문서를 지정하고 **웹사이트 엔드포인트**를 얻습니다.
- 웹사이트 엔드포인트는 **HTTP만** 지원합니다. **HTTPS와 사용자 도메인·캐싱**이 필요하면 앞에 **CloudFront**를 둡니다.
- 루트 도메인을 S3 정적 웹사이트로 연결하려면 Route 53 **Alias**(S3 웹사이트 엔드포인트 대상)를 사용합니다.

---

## ✍️ 시험 포인트

- **Alias = Zone Apex 가능 + 무료 + AWS 리소스 대상.** **CNAME = Zone Apex 불가.** 루트 도메인 → ALB/CloudFront는 **Alias**.
- **라우팅 7종**: Simple / Weighted(가중치 0~255) / Latency(네트워크 지연) / Failover(헬스체크) / Geolocation(위치) / Geoproximity(bias, Traffic Flow) / Multivalue(최대 8개).
- **Latency = 측정 지연**, **Geolocation = 지리적 위치**. 혼동 금지.
- **Failover는 헬스 체크 필수 연동.**
- **CloudFront 오리진 = S3·ALB·EC2·custom HTTP.** 캐시 동작은 **경로 패턴별**.
- **OAC + S3 Block Public Access** = S3 직접 접근 차단, CloudFront만 허용.
- **CloudFront용 ACM 인증서 = 반드시 us-east-1.**
- **캐시 갱신**: 무효화(즉시, 비용) vs **버전 파일명**(권장 운영 패턴).
- **S3 정적 웹사이트 엔드포인트 = HTTP만.** HTTPS는 앞에 CloudFront.

---

## ⚠️ 흔한 함정

1. **"루트 도메인(example.com)을 CNAME으로 ALB에 연결한다."** → CNAME은 **Zone Apex에 사용할 수 없습니다**. 루트 도메인은 **Alias** 레코드를 써야 합니다.

2. **"Geolocation은 가장 가까운/빠른 리전으로 보낸다."** → Geolocation은 **지리적 위치(국가·대륙)** 로만 결정하며 네트워크 속도를 보장하지 않습니다. "가장 빠른 응답"은 **Latency** 정책입니다.

3. **"CloudFront용 ACM 인증서를 서울 리전에서 발급했다."** → CloudFront는 **us-east-1** 의 ACM 인증서만 사용합니다. 다른 리전 인증서는 연결할 수 없습니다(ALB용 인증서는 ALB와 같은 리전).

4. **"콘텐츠를 바꿨는데 옛 버전이 보인다 → CloudFront 장애."** → 엣지 캐시 **TTL** 때문입니다. 즉시 갱신하려면 **무효화(Invalidation)** 를 하거나, 더 나은 운영으로 **버전 파일명**을 사용합니다.

5. **"무효화를 항상 `/*` 로 돌린다."** → 전체 무효화를 자주 하면 비용과 오리진 부하가 큽니다. 변경된 경로만 무효화하거나 버전 문자열 패턴으로 무효화 자체를 줄이는 것이 운영 정석입니다.

6. **"OAI가 현재 권장 방식이다."** → OAI(Origin Access Identity)는 구형입니다. 현재 권장은 **OAC(Origin Access Control)** 입니다.

7. **"S3 정적 웹사이트 엔드포인트로 HTTPS를 제공한다."** → S3 웹사이트 엔드포인트는 **HTTP만** 지원합니다. HTTPS·사용자 도메인·캐싱이 필요하면 **CloudFront**를 앞에 둡니다.

8. **"Multivalue 정책은 로드 밸런서다."** → Multivalue는 DNS가 최대 8개 정상 IP를 반환할 뿐, **세션 관리·연결 중개가 없는** DNS 기능입니다. 로드 밸런서가 필요하면 ELB를 씁니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** `example.com`(루트 도메인)을 Application Load Balancer로 연결해야 합니다. Route 53에서 어떤 레코드를 만드나요?

<details><summary>정답 보기</summary>

**Alias 레코드**를 만들어 ALB를 대상으로 지정합니다. CNAME은 DNS 표준상 Zone Apex(루트 도메인)에 사용할 수 없습니다. Alias는 Zone Apex에서도 동작하고, 쿼리 비용이 무료이며, ALB IP가 바뀌어도 자동으로 추적합니다. 서브도메인(`www`)이라면 CNAME도 가능하지만, AWS 리소스 대상이면 Alias가 권장됩니다.
</details>

**Q2.** 새로 배포한 `index.html`이 일부 사용자에게는 옛 버전으로 보입니다. CloudFront를 쓰고 있습니다. 즉시 최신으로 보이게 하려면?

<details><summary>정답 보기</summary>

엣지 캐시 **TTL** 때문에 옛 객체가 남아 있는 것입니다. 즉시 갱신하려면 **무효화(Invalidation)** 로 `/index.html`(또는 해당 경로)을 무효화합니다. 장기적으로는 무효화 비용을 줄이기 위해 **버전이 들어간 파일명**(예: `app.v2.js`)이나 적절한 `Cache-Control` 헤더로 캐시 동작을 설계하는 것이 운영상 더 낫습니다.
</details>

**Q3.** S3에 정적 사이트를 두고 CloudFront로 전 세계에 배포하되, 사용자가 S3 URL로 직접 접근하는 것을 막아야 합니다. 어떻게 구성하나요?

<details><summary>정답 보기</summary>

**CloudFront + OAC(Origin Access Control) + S3 퍼블릭 액세스 차단(Block Public Access)** 으로 구성합니다. S3 버킷 정책에 **CloudFront 서비스 주체만 허용**하는 조건을 추가하고, 버킷의 퍼블릭 액세스를 모두 차단합니다. 그러면 사용자는 CloudFront 도메인을 통해서만 콘텐츠에 접근하고, S3 URL 직접 접근은 403으로 차단됩니다. (OAI는 구형이므로 OAC를 사용)
</details>

**Q4.** 주 리전(서울)이 장애일 때 자동으로 보조 리전(도쿄)으로 트래픽을 넘기고 싶습니다. Route 53에서 어떤 정책과 부가 구성이 필요한가요?

<details><summary>정답 보기</summary>

**Failover 라우팅 정책**을 사용하고, Primary(서울)·Secondary(도쿄) 레코드를 만든 뒤 **각각에 상태 확인(Health Check)** 을 연결합니다. Primary 상태 확인이 실패하면 Route 53이 자동으로 Secondary 레코드를 반환합니다. 두 엔드포인트가 ALB라면 각 레코드는 ALB 대상 Alias로 만들고, 상태 확인은 엔드포인트 또는 CloudWatch 경보 기반으로 구성합니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 AWS 자료를 기준으로 작성했습니다. (작성·대조: 2026-06-09)

1. Amazon Route 53 개발자 가이드 — 소개 — https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html
2. Route 53 라우팅 정책 선택 — https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html
3. Alias 레코드와 비-Alias 레코드 비교 — https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html
4. Amazon CloudFront 개발자 가이드 — 소개 — https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html
5. CloudFront 캐시 무효화 — https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Invalidation.html
6. S3 정적 웹사이트 호스팅 — https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html
