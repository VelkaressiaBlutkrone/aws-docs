---
examGuideTaskId: saa-t3-7
certCode: SAA-C03
domain: 3
domainName: 고성능 아키텍처 설계
domainWeightPct: 24
title: 네트워크 성능 — Route 53·CloudFront·Global Accelerator·로드밸런서
coversTasks:
  - "3.4"
sources:
  - title: Amazon Route 53 개발자 가이드 — 소개 (공식)
    url: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html
  - title: Route 53 라우팅 정책 (공식)
    url: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html
  - title: Amazon CloudFront 개발자 가이드 — 소개 (공식)
    url: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html
  - title: AWS Global Accelerator 개발자 가이드 — 소개 (공식)
    url: https://docs.aws.amazon.com/global-accelerator/latest/dg/what-is-global-accelerator.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-07
---

# 네트워크 성능 — Route 53·CloudFront·Global Accelerator·로드밸런서

> **커버하는 공식 Task** — SAA-C03 · 도메인 3 「고성능 아키텍처 설계」(24%) · **Task 3.4 고성능·확장 네트워크 아키텍처 결정** (`saa-t3-7`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 글로벌 트래픽 라우팅·CDN·저지연 전달·로드 밸런싱은 시험 시나리오에서 반복적으로 등장합니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 3.4의 Skill 항목 기반)

- [ ] **Route 53 라우팅 정책 7종** — 각 정책의 동작과 대표 용도를 시나리오에 매핑할 수 있다
- [ ] **Alias vs CNAME** — Zone Apex 제약, 비용, 대상 차이를 설명할 수 있다
- [ ] **Route 53 헬스 체크** — Failover·Multivalue 정책과의 연계 방식을 설명할 수 있다
- [ ] **CloudFront CDN 동작 원리** — 엣지 로케이션·캐시 동작·오리진·TTL을 설명할 수 있다
- [ ] **OAC(Origin Access Control)** — S3 직접 접근을 차단하고 CloudFront만 허용하는 구성을 안다
- [ ] **Signed URL vs Signed Cookie** — 개별 파일 vs 다중 파일 접근 제한을 구분할 수 있다
- [ ] **Global Accelerator** — Anycast IP 2개·TCP/UDP 지원·비-HTTP 워크로드 적합성을 설명할 수 있다
- [ ] **CloudFront vs Global Accelerator 구분** — 캐싱 여부·프로토콜·IP 유형·적합 워크로드를 비교할 수 있다
- [ ] **로드 밸런서 성능 관점** — ALB·NLB·GLB의 성능 특성과 선택 기준을 설명할 수 있다

---

## 🎯 왜 중요한가

- 도메인 3(24%)에서 "글로벌 사용자에게 가장 빠르게", "DR 시 자동 전환", "고정 IP 필요", "S3 직접 접근 차단" 같은 시나리오가 반복 출제됩니다.
- Route 53 라우팅 정책 7종은 이름이 비슷해 혼동하기 쉬운 단골 함정입니다. Latency vs Geolocation, Geolocation vs Geoproximity의 차이를 숫자와 기준으로 구분해야 합니다.
- CloudFront와 Global Accelerator는 둘 다 "글로벌 저지연"을 키워드로 갖습니다. 캐싱 여부, 프로토콜, IP 고정 여부가 선택 기준입니다.
- CLF에서 개념 수준으로 봤다면, SAA는 **설계 결정**을 묻습니다. 7종 중 어떤 정책을, CloudFront/Global Accelerator 중 어느 것을, ALB/NLB 중 무엇을 — 각 시나리오에서 왜 선택하는지가 핵심입니다.

---

## 📖 핵심 개념

### 1) Amazon Route 53 — 관리형 DNS

> 공식 정의: **"고가용성·확장성 DNS 웹 서비스."** 도메인 등록, DNS 라우팅, 헬스 체크 세 가지 기능을 조합해 제공합니다.

Route 53은 **글로벌 서비스**입니다. 리전이 없고, DNS 쿼리 수에 따라 과금됩니다.

### 2) Alias vs CNAME (★ 단골 출제)

| 항목 | Alias 레코드 | CNAME 레코드 |
|---|---|---|
| **대상** | AWS 리소스 (ALB·CloudFront·S3 정적 웹사이트·API GW 등) | 임의의 도메인 |
| **Zone Apex 사용** | **가능** (example.com 직접 지정) | **불가** |
| **쿼리 비용** | **무료** | 일반 과금 |
| **IP 자동 추적** | AWS 리소스 IP 변경 시 자동 반영 | 직접 관리 필요 |

> 루트 도메인(example.com)을 ALB 또는 CloudFront로 보내야 할 때는 반드시 **Alias 레코드**를 사용합니다. CNAME은 Zone Apex에 사용할 수 없습니다.

### 3) Route 53 라우팅 정책 7종 (★ 핵심 비교)

| 정책 | 동작 원리 | 대표 용도 |
|---|---|---|
| **Simple(단순)** | 단일 레코드 반환 | 단일 리소스 기본 구성 |
| **Weighted(가중)** | 레코드별 가중치(0~255) 비율로 분배 | A/B 테스트, 점진 배포(Canary) |
| **Latency(지연시간)** | 사용자 위치 기준 **네트워크 지연이 가장 낮은** AWS 리전으로 | 글로벌 성능 최적화 |
| **Failover(장애조치)** | 헬스 체크 기반 — Primary 비정상 시 Secondary로 자동 전환 | DR, 액티브-패시브 고가용성 |
| **Geolocation(지리위치)** | **사용자의 지리적 위치(국가·대륙)** 기준 라우팅 | 콘텐츠 현지화, 지역 규제 준수 |
| **Geoproximity(지리근접)** | 리소스 위치 기준 + **bias(편향값)** 로 트래픽 이동 범위 조정 | 트래픽을 특정 리전으로 점진 이동 (Traffic Flow 필요) |
| **Multivalue Answer(다중값)** | 최대 8개 정상 레코드를 무작위 반환 + 헬스 체크 연동 | 단순 부하 분산 (로드 밸런서 대체 아님) |

> **Latency vs Geolocation 핵심 구분**: Latency는 **네트워크 지연 시간**(측정값)으로 결정, Geolocation은 **사용자 IP의 지리적 위치**로 결정합니다. "가장 빠른 응답"을 원하면 Latency, "국가별 다른 콘텐츠·규제"를 원하면 Geolocation입니다.

> **Geoproximity 주의**: Geoproximity는 **Route 53 Traffic Flow** 기능에서만 사용할 수 있습니다. bias 값을 양수로 설정하면 해당 리소스 쪽으로 더 많은 트래픽이 흐르고, 음수로 설정하면 줄어듭니다.

### 4) Route 53 헬스 체크

- **엔드포인트 헬스 체크**: HTTP·HTTPS·TCP로 엔드포인트 상태를 주기적으로 점검합니다.
- **계산형(Calculated) 헬스 체크**: 여러 하위 헬스 체크를 AND/OR 조합해 복합 상태 판별.
- **CloudWatch 알람 기반**: 알람 상태를 헬스 체크 결과로 사용.

헬스 체크와 연동되는 라우팅 정책:
- **Failover** — Primary 헬스 체크 실패 시 Secondary로 자동 전환 (필수 연동).
- **Multivalue Answer** — 비정상 엔드포인트를 응답 목록에서 자동 제외.
- **Weighted / Latency / Geolocation** — 헬스 체크 실패 레코드를 응답에서 제외해 자동 우회.

### 5) Amazon CloudFront — 글로벌 CDN

> 공식 정의: **"정적·동적 웹 콘텐츠를 전 세계 사용자에게 빠르게 배포하는 웹 서비스."** 전 세계의 엣지 로케이션에 콘텐츠를 캐싱해 지연을 줄이고 오리진 부하를 경감합니다.

#### 주요 구성요소

| 요소 | 설명 |
|---|---|
| **Origin(오리진)** | 원본 서버 — S3 버킷, ALB, EC2, 임의 HTTP 서버 |
| **Edge Location(엣지 로케이션)** | 전 세계 캐싱·전송 지점. AWS 리전 수보다 훨씬 많음 |
| **Distribution(배포)** | CloudFront 구성 단위 — 오리진·캐시 동작·도메인 설정 묶음 |
| **Cache Behavior(캐시 동작)** | 경로 패턴별 캐시 정책, TTL, 압축, 헤더 전달 규칙 |
| **OAC** (Origin Access Control) | S3를 CloudFront 경유로만 접근 허용 (OAI의 후속·현재 권장 방식) |

#### S3 오리진 보호 구성

```
사용자 → CloudFront Edge → (OAC) → S3 버킷 (Block Public Access ON)
사용자가 S3 URL 직접 접근 시도 → 차단 (403 Forbidden)
```

OAC를 사용하면 S3 버킷 정책에 CloudFront 서비스 주체(Service Principal)만 허용하는 조건을 추가합니다. Block Public Access를 활성화하면 퍼블릭 접근 자체가 차단됩니다.

#### Signed URL vs Signed Cookie (접근 제한)

| 방식 | 사용 상황 |
|---|---|
| **Signed URL** | **단일 파일** 단위 임시 접근 제한 — 특정 영상 한 편, 특정 다운로드 파일 |
| **Signed Cookie** | **복수 파일 / 세션** 단위 접근 제한 — 회원 전용 콘텐츠 패키지, 스트리밍 세션 |

#### CloudFront 보안·기타

- **WAF(Web Application Firewall) 연동** — SQL Injection·XSS 등 웹 공격 방어.
- **지역 제한(Geo Restriction)** — 특정 국가에서의 접근을 허용/차단.
- **HTTPS 강제** — 뷰어-CloudFront 구간, CloudFront-오리진 구간 모두 설정 가능.
- **ACM 인증서는 반드시 `us-east-1`** — CloudFront와 연결할 SSL/TLS 인증서는 버지니아 북부 리전에서 발급해야 합니다.

### 6) AWS Global Accelerator — 네트워크 경로 최적화

> 공식 정의: **"가속기를 생성해 글로벌 및 로컬 사용자의 애플리케이션 성능을 개선하는 서비스."** AWS 글로벌 네트워크를 통해 트래픽을 사용자와 가장 가까운 리전 엔드포인트로 라우팅합니다.

**핵심 특성:**

- **Anycast 고정 IP 2개(IPv4)** — 두 IP는 전 세계 어느 엣지에서도 동일하게 수신. 클라이언트 고정 IP 화이트리스트 시나리오에 적합.
- **TCP/UDP 모두 지원** — HTTP가 아닌 프로토콜(게임·IoT·VoIP·DNS)에 활용 가능.
- **캐싱 없음** — 데이터를 저장하지 않고 경로만 최적화.
- **헬스 체크 자동 페일오버** — 엔드포인트 비정상 시 즉시 정상 엔드포인트로 트래픽 전환.
- **엔드포인트 유형** — NLB·ALB·EC2 인스턴스·Elastic IP.

### 7) CloudFront vs Global Accelerator 비교 (★ 단골 출제)

| 항목 | Amazon CloudFront | AWS Global Accelerator |
|---|---|---|
| **주목적** | 콘텐츠 **캐싱** (CDN) | 네트워크 **경로 최적화** |
| **프로토콜** | HTTP / HTTPS | **TCP / UDP** (비-HTTP 포함) |
| **캐싱** | 있음 (TTL 기반) | 없음 |
| **진입 IP** | 도메인 기반 (가변) | **고정 Anycast IP 2개** |
| **콘텐츠 처리** | 엣지에서 캐시·서빙 | 엣지에서 경로만 결정 후 오리진으로 전달 |
| **적합 워크로드** | 정적/동적 웹, 스트리밍, API | 게임·IoT·VoIP·**고정 IP 필요**, 비-HTTP |
| **가격 클래스** | 리전별 엣지 선택 가능 | 없음 |

> CloudFront와 Global Accelerator는 함께 사용할 수 있습니다. CloudFront 앞에 Global Accelerator를 붙여 고정 IP를 제공하면서 CDN 캐싱도 활용하는 구성이 가능합니다.

### 8) 로드 밸런서 성능 관점

AWS ELB(Elastic Load Balancing)는 세 가지 유형이 있으며, 시험에서는 성능·프로토콜 기준으로 선택 문제가 출제됩니다.

| 유형 | 계층 | 프로토콜 | 성능 특성 | 대표 용도 |
|---|---|---|---|---|
| **ALB** (Application LB) | L7 | HTTP·HTTPS·WebSocket | 경로/호스트 기반 라우팅, Lambda·컨테이너 대상 | 마이크로서비스, REST API |
| **NLB** (Network LB) | L4 | TCP·UDP·TLS | **초고성능·초저지연**, **고정 IP** 지원, 수백만 RPS | TCP 실시간 게임, 금융 거래, IoT |
| **GLB** (Gateway LB) | L3/L4 | IP | 트래픽을 어플라이언스(방화벽·IDS 등)로 투명하게 전달 | 네트워크 어플라이언스 통합 |

> **NLB 선택 신호**: "초저지연", "TCP/UDP", "고정 IP", "수백만 요청/초" — 이 키워드가 보이면 NLB입니다.
> **ALB 선택 신호**: "경로 기반 라우팅", "호스트 기반 라우팅", "Lambda 대상", "컨테이너(ECS/EKS)".

---

## ✍️ 시험 포인트

| 시나리오 키워드 | 정답 |
|---|---|
| "가장 낮은 지연 리전으로 라우팅" | Route 53 **Latency 정책** |
| "주 리전 장애 시 보조 리전으로 자동 전환" | Route 53 **Failover 정책** + 헬스 체크 |
| "트래픽 10%만 신버전으로 점진 배포" | Route 53 **Weighted 정책** |
| "국가별 다른 콘텐츠, 지역 규제 준수" | Route 53 **Geolocation 정책** |
| "루트 도메인(example.com)을 ALB로" | Route 53 **Alias 레코드** |
| "글로벌 정적 콘텐츠 빠르게 배포" | **CloudFront** |
| "S3 직접 접근 차단, CDN 경유만 허용" | CloudFront + **OAC** + S3 Block Public Access |
| "유료 회원 전용 단일 파일 임시 접근" | CloudFront **Signed URL** |
| "회원 전용 복수 파일 세션 접근 제한" | CloudFront **Signed Cookie** |
| "UDP 게임·IoT·VoIP, 고정 IP 필요" | **Global Accelerator** |
| "비-HTTP, TCP/UDP 초저지연 라우팅" | **Global Accelerator** |
| "CloudFront에 고정 IP를 부여하고 싶다" | **Global Accelerator** + CloudFront 조합 |
| "L4, TCP, 초고성능, 고정 IP 로드 밸런서" | **NLB** |
| "경로 기반 라우팅, 컨테이너·Lambda 대상" | **ALB** |

**추가 포인트:**

- **Geoproximity vs Geolocation**: Geolocation은 사용자 IP 위치가 기준, Geoproximity는 리소스 위치 + bias 값이 기준. Geoproximity는 Traffic Flow 필요.
- **Multivalue Answer는 로드 밸런서가 아닙니다**: DNS 쿼리에 최대 8개 정상 IP를 반환하지만, 로드 밸런서의 연결 지속성·세션 관리는 없습니다.
- **CloudFront ACM 인증서 리전**: 반드시 `us-east-1`. 다른 리전에서 발급한 인증서는 CloudFront에 연결 불가.
- **OAC vs OAI**: OAI(Origin Access Identity)는 구형. 현재 AWS 권장은 OAC(Origin Access Control).

---

## ⚠️ 흔한 함정

1. **"Geolocation은 가장 가까운 리전으로 보낸다."** — 아닙니다. Geolocation은 사용자 IP의 **지리적 위치(국가·대륙)** 로만 결정하며, 가장 빠른 경로를 보장하지 않습니다. 네트워크 지연 기준으로 라우팅하려면 **Latency 정책**을 사용해야 합니다.

2. **"CNAME 레코드를 Zone Apex(example.com)에 사용하면 된다."** — CNAME은 Zone Apex에 사용할 수 없습니다. DNS 표준 제약입니다. 루트 도메인을 AWS 리소스로 보내려면 **Alias 레코드**를 사용합니다.

3. **"Global Accelerator는 CloudFront처럼 콘텐츠를 캐싱한다."** — 아닙니다. Global Accelerator는 **네트워크 경로만 최적화**하며 캐싱 기능이 없습니다. 캐싱이 필요하면 CloudFront를 사용해야 합니다.

4. **"글로벌 저지연이 필요하면 항상 CloudFront."** — 비-HTTP(UDP·TCP 게임·IoT 등) 또는 **고정 IP**가 필요한 시나리오에서는 **Global Accelerator**가 정답입니다.

5. **"Geoproximity는 별도 설정 없이 사용할 수 있다."** — Geoproximity는 **Route 53 Traffic Flow** 기능에서만 사용 가능합니다. Traffic Flow 없이는 설정할 수 없습니다.

6. **"CloudFront용 ACM 인증서를 서울 리전(ap-northeast-2)에서 발급했다."** — CloudFront는 **us-east-1(버지니아 북부)** 에서 발급한 ACM 인증서만 사용할 수 있습니다.

7. **"Multivalue Answer 정책은 로드 밸런서와 동일하다."** — Multivalue Answer는 DNS 레벨에서 복수 IP를 반환하는 것이며, 실제 연결을 중개하는 로드 밸런서가 아닙니다. 세션 지속성·상태 추적이 필요하면 로드 밸런서를 사용해야 합니다.

8. **"OAI(Origin Access Identity)가 현재 권장 방식이다."** — OAI는 구형 방식입니다. 현재 AWS 권장은 **OAC(Origin Access Control)**입니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 글로벌 서비스를 운영 중입니다. 한국·미국·유럽 세 리전에 서버가 있고, 각 사용자를 네트워크 응답이 가장 빠른 리전으로 보내야 합니다. 어떤 Route 53 라우팅 정책을 사용하나요?

<details><summary>정답 보기</summary>

**Latency(지연시간) 라우팅 정책**을 사용합니다. Route 53은 각 리전에 대한 사용자의 실제 네트워크 지연을 측정해 가장 낮은 지연의 리전으로 라우팅합니다. Geolocation은 사용자의 지리적 위치(국가·대륙)만 보기 때문에, 물리적으로 가깝더라도 네트워크 경로상 더 느릴 수 있습니다. 네트워크 성능 기준으로 라우팅하려면 Latency 정책이 정확합니다.
</details>

**Q2.** example.com(루트 도메인)을 Application Load Balancer로 라우팅해야 합니다. Route 53에서 어떤 레코드 유형을 사용하나요?

<details><summary>정답 보기</summary>

**Alias 레코드**를 사용합니다. CNAME 레코드는 DNS 표준상 Zone Apex(루트 도메인)에 사용할 수 없습니다. Alias 레코드는 AWS 리소스(ALB·CloudFront·S3 등)를 대상으로 Zone Apex에서도 사용할 수 있으며, 쿼리 비용도 무료입니다. ALB의 IP가 변경되어도 Alias가 자동으로 추적합니다.
</details>

**Q3.** 전 세계 사용자에게 이미지·JS·CSS를 빠르게 제공해야 하며, S3 버킷에 대한 직접 퍼블릭 접근은 차단하고 싶습니다. 어떻게 구성하나요?

<details><summary>정답 보기</summary>

**CloudFront 배포 + OAC(Origin Access Control) + S3 Block Public Access ON**으로 구성합니다. S3 버킷의 퍼블릭 접근을 완전히 차단하고, CloudFront OAC를 통해 CloudFront 배포만 S3에 접근할 수 있도록 S3 버킷 정책을 설정합니다. 사용자는 CloudFront 도메인을 통해서만 콘텐츠에 접근하며, 엣지 로케이션 캐싱으로 지연도 줄어듭니다.
</details>

**Q4.** UDP 기반 실시간 멀티플레이어 게임 서버를 AWS에 배포합니다. 전 세계 플레이어가 고정 IP로 접속해야 하며, 초저지연이 필요합니다. 어떤 서비스를 선택하나요?

<details><summary>정답 보기</summary>

**AWS Global Accelerator**를 사용합니다. Global Accelerator는 TCP/UDP를 모두 지원하며, Anycast 고정 IP 2개를 제공해 클라이언트가 항상 같은 IP로 접속할 수 있습니다. AWS 글로벌 백본 네트워크를 통해 최적 경로로 트래픽을 전달해 초저지연을 달성합니다. CloudFront는 HTTP/HTTPS 전용이므로 UDP 게임 트래픽에는 사용할 수 없습니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07)

1. Amazon Route 53 개발자 가이드 — 소개 — https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html
2. Route 53 라우팅 정책 — https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html
3. Amazon CloudFront 개발자 가이드 — 소개 — https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html
4. AWS Global Accelerator 개발자 가이드 — 소개 — https://docs.aws.amazon.com/global-accelerator/latest/dg/what-is-global-accelerator.html
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
