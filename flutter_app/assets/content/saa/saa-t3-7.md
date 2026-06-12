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

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **도메인 네임 시스템** | DNS (Domain Name System) | 사람이 읽는 도메인 이름을 컴퓨터가 사용하는 IP 주소로 변환하는 분산 이름 해석 체계 |
| **오리진** | Origin | CloudFront가 캐시 미스 시 콘텐츠를 가져오는 원본 서버 — S3·ALB·EC2 등 |
| **엣지 로케이션** | Edge Location | 사용자와 가까운 곳에 배치된 캐싱·전송 지점으로, AWS 리전보다 수십 배 많음 |
| **헬스 체크** | Health Check | 엔드포인트에 주기적으로 요청을 보내 정상 여부를 판별하는 모니터링 메커니즘 |
| **페일오버** | Failover | 주(Primary) 엔드포인트 장애 시 예비(Secondary) 엔드포인트로 트래픽을 자동 전환하는 절차 |
| **웹 방화벽** | WAF (Web Application Firewall) | HTTP 트래픽을 검사해 SQL Injection·XSS 같은 웹 계층 공격을 탐지·차단하는 보안 서비스 |

---

## 📖 핵심 개념

### 1) Amazon Route 53 — 관리형 DNS

> 공식 정의: **"고가용성·확장성 DNS 웹 서비스."** 도메인 등록, DNS 라우팅, 헬스 체크 세 가지 기능을 조합해 제공합니다.

Route 53은 **글로벌 서비스**입니다. 리전이 없고, DNS 쿼리 수에 따라 과금됩니다.

> 🧠 원리: 왜 Route 53은 특정 리전에 속하지 않는 글로벌 서비스로 설계됐을까요?
> DNS는 전 세계 사용자의 첫 번째 네트워크 요청을 처리하므로, 단일 리전에 배치하면 그 리전에서 멀리 떨어진 사용자가 도메인 이름을 해석하는 데 추가 지연이 발생합니다.
> Route 53은 전 세계 여러 위치의 DNS 서버 네트워크를 통해 사용자와 가까운 지점에서 이름 해석을 처리해, 리전 구분 없이 일관된 응답 속도를 제공합니다.
> 리전 장애와도 무관하게 동작해야 DNS 자체가 가용성 병목이 되지 않으므로, 글로벌 분산 구조가 서비스의 전제 조건이 됩니다.

### 2) Alias vs CNAME (★ 단골 출제)

| 항목 | Alias 레코드 | CNAME 레코드 |
|---|---|---|
| **대상** | AWS 리소스 (ALB·CloudFront·S3 정적 웹사이트·API GW 등) | 임의의 도메인 |
| **Zone Apex 사용** | **가능** (example.com 직접 지정) | **불가** |
| **쿼리 비용** | **무료** | 일반 과금 |
| **IP 자동 추적** | AWS 리소스 IP 변경 시 자동 반영 | 직접 관리 필요 |

> 루트 도메인(example.com)을 ALB 또는 CloudFront로 보내야 할 때는 반드시 **Alias 레코드**를 사용합니다. CNAME은 Zone Apex에 사용할 수 없습니다.

> 🧠 원리: 왜 Zone Apex에는 CNAME을 쓸 수 없고 Alias가 필요할까요?
> DNS 프로토콜은 CNAME이 있는 이름에 다른 레코드(NS·SOA 등)가 공존할 수 없도록 규정합니다.
> Zone Apex(루트 도메인)는 DNS 영역 자체의 NS·SOA 레코드를 반드시 보유해야 하므로, 그 이름에 CNAME을 추가하면 표준 위반이 되어 해석기가 정상 동작하지 않을 수 있습니다.
> Alias는 Route 53 전용 확장으로, 실제로 레코드 유형이 A 또는 AAAA로 동작하면서 AWS 리소스의 현재 IP를 자동으로 따라가 Zone Apex 제약을 우회합니다.
> 이 메커니즘 덕분에 루트 도메인을 ALB·CloudFront 같은 가변 IP 리소스로 안전하게 연결할 수 있습니다.

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

> 🧠 원리: 왜 Latency 정책은 사용자의 "지리적 위치"가 아닌 "실측 지연"을 기준으로 라우팅할까요?
> 지리적 거리가 가깝더라도 인터넷 경로·피어링 상태에 따라 실제 왕복 지연이 크게 달라질 수 있어, 물리적 위치만으로 "가장 빠른 리전"을 결정하면 오라우팅이 발생합니다.
> Route 53은 리전별로 누적된 네트워크 지연 측정 데이터를 기반으로 각 사용자 요청에 가장 낮은 지연 리전을 선택하므로, 실제 응답 속도 최적화가 목표일 때 Latency 정책이 Geolocation보다 정확합니다.
> 반면 Geolocation은 "어떤 리소스를 사용할 수 있는가"를 지리 규칙으로 제어하는 것이 목적이므로, 두 정책은 최적화 목표 자체가 다릅니다.

### 4) Route 53 헬스 체크

- **엔드포인트 헬스 체크**: HTTP·HTTPS·TCP로 엔드포인트 상태를 주기적으로 점검합니다.
- **계산형(Calculated) 헬스 체크**: 여러 하위 헬스 체크를 AND/OR 조합해 복합 상태 판별.
- **CloudWatch 알람 기반**: 알람 상태를 헬스 체크 결과로 사용.

헬스 체크와 연동되는 라우팅 정책:
- **Failover** — Primary 헬스 체크 실패 시 Secondary로 자동 전환 (필수 연동).
- **Multivalue Answer** — 비정상 엔드포인트를 응답 목록에서 자동 제외.
- **Weighted / Latency / Geolocation** — 헬스 체크 실패 레코드를 응답에서 제외해 자동 우회.

> 🧠 원리: 왜 Failover 정책에서 헬스 체크 연동은 선택이 아니라 필수일까요?
> Failover 정책은 Primary가 비정상일 때 Secondary로 전환하는 것이 유일한 목적인데, 비정상 여부를 판별할 수단이 없으면 전환 트리거가 존재하지 않습니다.
> 헬스 체크가 없으면 Route 53은 Primary의 상태를 알 방법이 없어 장애가 발생해도 계속 Primary 주소를 반환하므로, 페일오버 자체가 동작하지 않습니다.
> 반면 Weighted·Latency·Geolocation 정책은 헬스 체크 없이도 라우팅이 동작하되, 연동 시 비정상 레코드를 응답에서 자동 제외하는 부가 가용성을 얻습니다.

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

> 🧠 원리: 왜 CloudFront는 엣지 로케이션에서 캐시 미스가 나도 성능 이점이 있을까요?
> 캐시 미스 시에도 사용자 → 엣지 로케이션 구간은 공용 인터넷보다 짧아, 이 구간의 지연을 줄이는 효과는 그대로 유지됩니다.
> 엣지 → 오리진 구간은 AWS 내부 네트워크를 통해 전달되므로, 사용자가 오리진에 직접 연결하는 것보다 경로가 안정적일 수 있습니다.
> 이 구조 덕분에 CloudFront는 정적 콘텐츠의 캐시 히트 성능뿐 아니라, 동적 콘텐츠 전달의 경로 안정성도 함께 높이는 역할을 합니다.

### 6) AWS Global Accelerator — 네트워크 경로 최적화

> 공식 정의: **"가속기를 생성해 글로벌 및 로컬 사용자의 애플리케이션 성능을 개선하는 서비스."** AWS 글로벌 네트워크를 통해 트래픽을 사용자와 가장 가까운 리전 엔드포인트로 라우팅합니다.

**핵심 특성:**

- **Anycast 고정 IP 2개(IPv4)** — 두 IP는 전 세계 어느 엣지에서도 동일하게 수신. 클라이언트 고정 IP 화이트리스트 시나리오에 적합.
- **TCP/UDP 모두 지원** — HTTP가 아닌 프로토콜(게임·IoT·VoIP·DNS)에 활용 가능.
- **캐싱 없음** — 데이터를 저장하지 않고 경로만 최적화.
- **헬스 체크 자동 페일오버** — 엔드포인트 비정상 시 즉시 정상 엔드포인트로 트래픽 전환.
- **엔드포인트 유형** — NLB·ALB·EC2 인스턴스·Elastic IP.

> 🧠 원리: 왜 Global Accelerator는 Anycast IP 방식을 사용해 고정 IP를 제공할까요?
> Anycast는 동일한 IP 주소를 여러 지리적 위치에서 동시에 광고해, 사용자 요청이 자동으로 가장 가까운 위치로 라우팅되는 IP 라우팅 방식입니다.
> 두 개의 Anycast IP가 변하지 않으므로 클라이언트 방화벽·화이트리스트를 한 번만 설정하면 되고, 엔드포인트나 리전이 바뀌어도 IP를 재등록할 필요가 없습니다.
> Global Accelerator는 이 Anycast 특성을 활용해 진입 IP 고정과 가장 가까운 엣지 진입이라는 두 목표를 동시에 달성합니다.

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

> 🧠 원리: 왜 캐싱이 필요한지 여부가 CloudFront와 Global Accelerator의 선택 기준이 될까요?
> CloudFront는 엣지 로케이션에 콘텐츠 사본을 저장해 동일 요청에 오리진을 거치지 않고 응답하므로, 반복 요청이 많은 정적·동적 웹 콘텐츠에서 오리진 부하를 줄입니다.
> Global Accelerator는 데이터를 저장하지 않고 패킷을 최적 경로로 오리진까지 전달만 하므로, 캐시 불가 콘텐츠나 상태 기반 프로토콜(TCP 게임·VoIP)에도 적용할 수 있습니다.
> 결국 "콘텐츠를 엣지에서 끊을 수 있는가"가 두 서비스의 역할 분기점이며, HTTP가 아닌 프로토콜과 고정 IP 요구는 자동으로 Global Accelerator 쪽을 가리킵니다.

### 8) 로드 밸런서 성능 관점

AWS ELB(Elastic Load Balancing)는 세 가지 유형이 있으며, 시험에서는 성능·프로토콜 기준으로 선택 문제가 출제됩니다.

| 유형 | 계층 | 프로토콜 | 성능 특성 | 대표 용도 |
|---|---|---|---|---|
| **ALB** (Application LB) | L7 | HTTP·HTTPS·WebSocket | 경로/호스트 기반 라우팅, Lambda·컨테이너 대상 | 마이크로서비스, REST API |
| **NLB** (Network LB) | L4 | TCP·UDP·TLS | **초고성능·초저지연**, **고정 IP** 지원, 수백만 RPS | TCP 실시간 게임, 금융 거래, IoT |
| **GLB** (Gateway LB) | L3/L4 | IP | 트래픽을 어플라이언스(방화벽·IDS 등)로 투명하게 전달 | 네트워크 어플라이언스 통합 |

> **NLB 선택 신호**: "초저지연", "TCP/UDP", "고정 IP", "수백만 요청/초" — 이 키워드가 보이면 NLB입니다.
> **ALB 선택 신호**: "경로 기반 라우팅", "호스트 기반 라우팅", "Lambda 대상", "컨테이너(ECS/EKS)".

> 🧠 원리: 왜 NLB는 L7인 ALB보다 더 높은 처리량과 낮은 지연을 달성할 수 있을까요?
> ALB는 HTTP 헤더·경로·호스트를 파싱해 라우팅 결정을 내리므로, 각 연결에서 L7 패킷 분석 처리가 추가됩니다.
> NLB는 L4에서 TCP·UDP 흐름만 보고 대상 엔드포인트로 전달하므로, 패킷당 처리 단계가 줄어 지연과 처리 비용이 낮게 유지됩니다.
> 이 계층 차이가 "초고성능·초저지연이 필요하면 NLB, 콘텐츠 기반 라우팅이 필요하면 ALB"라는 선택 원칙의 기술적 근거입니다.

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
   *(원리: §3 — Latency는 실측 지연으로 라우팅하고 Geolocation은 지리 규칙으로 접근 가능 리소스를 제어하므로 최적화 목표 자체가 다르다.)*

2. **"CNAME 레코드를 Zone Apex(example.com)에 사용하면 된다."** — CNAME은 Zone Apex에 사용할 수 없습니다. DNS 표준 제약입니다. 루트 도메인을 AWS 리소스로 보내려면 **Alias 레코드**를 사용합니다.
   *(원리: §2 — Zone Apex는 NS·SOA 레코드를 반드시 보유해야 해 CNAME과 공존 불가이므로, Alias가 A/AAAA 유형으로 동작하며 제약을 우회한다.)*

3. **"Global Accelerator는 CloudFront처럼 콘텐츠를 캐싱한다."** — 아닙니다. Global Accelerator는 **네트워크 경로만 최적화**하며 캐싱 기능이 없습니다. 캐싱이 필요하면 CloudFront를 사용해야 합니다.
   *(원리: §7 — 콘텐츠를 엣지에서 끊을 수 있는가가 두 서비스의 역할 분기점이며, Global Accelerator는 경로만 결정하고 오리진으로 전달한다.)*

4. **"글로벌 저지연이 필요하면 항상 CloudFront."** — 비-HTTP(UDP·TCP 게임·IoT 등) 또는 **고정 IP**가 필요한 시나리오에서는 **Global Accelerator**가 정답입니다.
   *(원리: §7 — HTTP가 아닌 프로토콜과 고정 IP 요구는 자동으로 Global Accelerator를 가리키며, CloudFront는 HTTP/HTTPS 전용이다.)*

5. **"Geoproximity는 별도 설정 없이 사용할 수 있다."** — Geoproximity는 **Route 53 Traffic Flow** 기능에서만 사용 가능합니다. Traffic Flow 없이는 설정할 수 없습니다.
   *(원리: §3 본문 — Geoproximity는 Traffic Flow 기능에서만 bias 값과 함께 사용 가능하다.)*

6. **"CloudFront용 ACM 인증서를 서울 리전(ap-northeast-2)에서 발급했다."** — CloudFront는 **us-east-1(버지니아 북부)** 에서 발급한 ACM 인증서만 사용할 수 있습니다.
   *(원리: §5 본문 — CloudFront에 연결할 SSL/TLS 인증서는 반드시 us-east-1에서 발급해야 한다.)*

7. **"Multivalue Answer 정책은 로드 밸런서와 동일하다."** — Multivalue Answer는 DNS 레벨에서 복수 IP를 반환하는 것이며, 실제 연결을 중개하는 로드 밸런서가 아닙니다. 세션 지속성·상태 추적이 필요하면 로드 밸런서를 사용해야 합니다.
   *(원리: §3 본문 — Multivalue Answer는 최대 8개 정상 레코드를 무작위 반환하는 DNS 응답이며, 연결 지속성·세션 관리를 제공하는 로드 밸런서와 다르다.)*

8. **"OAI(Origin Access Identity)가 현재 권장 방식이다."** — OAI는 구형 방식입니다. 현재 AWS 권장은 **OAC(Origin Access Control)**입니다.
   *(원리: §5 본문 — AWS는 OAI 대신 OAC를 현재 권장하며, OAC는 S3 버킷 정책에 CloudFront 서비스 주체 조건을 적용하는 방식이다.)*

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

**Q5 (원리).** 왜 NLB는 ALB에 비해 더 높은 처리량과 낮은 지연을 달성할 수 있나요?

<details><summary>정답 보기</summary>

NLB는 L4(TCP·UDP) 수준에서 패킷 흐름만 보고 대상 엔드포인트로 전달하므로, 각 연결마다 수행하는 처리 단계가 적습니다. ALB는 HTTP 헤더·경로·호스트를 파싱해 라우팅 결정을 내리는 L7 처리가 필요해, 요청당 처리 비용이 추가됩니다. 이 계층 차이가 "초고성능·초저지연" 요구에 NLB가, 콘텐츠 기반 라우팅 요구에 ALB가 각각 선택되는 기술적 근거입니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07)

1. Amazon Route 53 개발자 가이드 — 소개 — https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html
2. Route 53 라우팅 정책 — https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html
3. Amazon CloudFront 개발자 가이드 — 소개 — https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html
4. AWS Global Accelerator 개발자 가이드 — 소개 — https://docs.aws.amazon.com/global-accelerator/latest/dg/what-is-global-accelerator.html
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
