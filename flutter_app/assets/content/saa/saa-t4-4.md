---
examGuideTaskId: saa-t4-4
certCode: SAA-C03
domain: 4
domainName: 비용에 최적화된 아키텍처 설계
domainWeightPct: 20
title: 비용 최적화 네트워크 — NAT 전략·전송 비용·CDN·피어링·PrivateLink
coversTasks:
  - "4.4"
sources:
  - title: VPC 게이트웨이 엔드포인트 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html
  - title: NAT 게이트웨이 요금 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-pricing.html
  - title: Amazon VPC 요금 (공식)
    url: https://aws.amazon.com/vpc/pricing/
  - title: AWS PrivateLink 요금 (공식)
    url: https://aws.amazon.com/privatelink/pricing/
  - title: Amazon CloudFront 요금 (공식)
    url: https://aws.amazon.com/cloudfront/pricing/
  - title: AWS Direct Connect 요금 (공식)
    url: https://aws.amazon.com/directconnect/pricing/
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-10-24
---

# 비용 최적화 네트워크 — NAT 전략·전송 비용·CDN·피어링·PrivateLink

> **커버하는 공식 Task** — SAA-C03 · 도메인 4 「비용에 최적화된 아키텍처 설계」(20%) · **Task 4.4 네트워크 아키텍처의 비용 최적화**(`saa-t4-4`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 네트워크 서비스·토폴로지 자체는 saa-t3-7·t3-8에서 다루며, 여기서는 **비용** 관점에 집중합니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다.

- [ ] **데이터 전송 비용 구조** — 인바운드·아웃바운드·같은 AZ·교차 AZ·교차 리전·인터넷 전송의 과금 규칙을 말할 수 있다
- [ ] **NAT Gateway 절감** — S3·DynamoDB 트래픽을 Gateway Endpoint로 우회해 NAT 처리 요금을 없애는 이유를 설명할 수 있다
- [ ] **AZ 배치 전략** — NAT Gateway와 리소스를 같은 AZ에 두는 것이 왜 비용에 영향을 미치는지 안다
- [ ] **CloudFront 절감 원리** — 오리진 아웃바운드 비용이 어떻게 줄어드는지 설명할 수 있다
- [ ] **VPC 엔드포인트 유형별 비용** — Gateway(무료) vs Interface(유료)를 구별하고, 선택 기준을 안다
- [ ] **VPC 피어링 vs Transit Gateway** — 연결 수와 비용 트레이드오프를 시나리오로 설명할 수 있다
- [ ] **Direct Connect 단가 위치** — 인터넷 대비 Direct Connect 전송 단가를 알고, 언제 비용 절감이 되는지 안다

---

## 🎯 왜 중요한가

- 도메인 4(20%)에서 네트워크 비용 최적화는 스토리지·컴퓨팅 절감과 함께 출제 비중이 높습니다. 시험은 아키텍처 다이어그램 시나리오를 주고 "어느 변경이 전송 비용을 가장 줄이는가"를 묻습니다.
- 데이터 전송 요금은 겉으로 드러나지 않다가 규모가 커지면 청구서에 큰 비중을 차지합니다. AWS는 이를 **숨겨진 세금(hidden tax)**이라고 부르기도 합니다.
- 핵심 패턴은 두 가지입니다. 첫째, 불필요한 경로(NAT 경유, 인터넷 경유)를 없애는 것. 둘째, 캐싱(CloudFront)으로 오리진 전송 횟수 자체를 줄이는 것.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **프라이빗 서브넷** | Private Subnet | 인터넷 게이트웨이 경로가 없어 외부에서 직접 접근 불가한 서브넷 — 내부 DB·앱 서버 배치에 사용 |
| **온프레미스** | On-Premises | 기업이 자체 데이터센터에 서버·네트워크 장비를 직접 운영하는 환경 |
| **고가용성** | High Availability (HA) | 장애 시에도 서비스가 계속 운영되도록 여러 AZ에 리소스를 분산하는 설계 원칙 |
| **캐시 히트율** | Cache Hit Ratio | 캐시에서 응답한 요청 비율 — 높을수록 오리진 접근이 줄어 전송 비용이 낮아짐 |
| **Multi-AZ** | Multi-AZ Deployment | 동일 리전 내 두 개 이상의 가용 영역에 걸쳐 리소스를 배치해 AZ 장애를 대비하는 구성 |

---

## 📖 핵심 개념 {#core-concepts}

### 1) 데이터 전송 비용 구조 {#data-transfer-cost-structure}

AWS 데이터 전송 비용은 **방향과 경계**에 따라 결정됩니다.

| 전송 유형 | 비용 | 비고 |
|---|---|---|
| 인터넷 → AWS (인바운드) | 무료 | 방향 무관, 항상 무료 |
| 같은 AZ 내 인스턴스 간 (프라이빗 IP) | 무료 | 퍼블릭 IP 사용 시 과금 주의 |
| 교차 AZ (같은 리전, 프라이빗 IP) | $0.01/GB (양방향) | 가용성 ↑ → 비용 ↑ |
| 교차 리전 | $0.02/GB 수준 (리전별 상이) | 리전마다 단가 다름 |
| AWS → 인터넷 (아웃바운드) | $0.09/GB 수준 (첫 10TB) | 월 100GB 무료 포함 |

> **시험 핵심**: 인바운드는 무료, 아웃바운드는 과금. 같은 AZ 프라이빗 IP는 무료, 교차 AZ는 유료. 이 두 규칙이 설계 결정의 근거입니다.

**교차 AZ 비용이 생기는 이유**

고가용성을 위해 Multi-AZ로 리소스를 분산하면, AZ 간 트래픽이 발생합니다. 예를 들어 AZ-A의 EC2가 AZ-B의 RDS에 접근하거나, 로드 밸런서가 여러 AZ에 걸쳐 요청을 분산하면 교차 AZ 전송 요금이 누적됩니다.

> 🧠 원리: 왜 Multi-AZ 배치는 가용성을 높이는 동시에 전송 비용도 높일까요?
> AZ는 물리적으로 분리된 데이터센터이므로, AZ 경계를 넘는 데이터는 AZ 간 네트워크 인프라를 경유합니다. AWS는 이 교차 AZ 구간 사용을 별도로 과금합니다.
> 결과적으로 "장애 격리 범위를 넓힌다"는 설계 결정이 "경계를 넘는 트래픽 비용"으로 이어지며, 두 목표는 항상 상충합니다.
> 이 구조 때문에 AZ 배치는 가용성 요구와 트래픽 패턴을 함께 고려해야 비용을 예측할 수 있습니다.

### 2) NAT Gateway 비용 구조와 절감 {#nat-gateway-cost}

NAT Gateway는 프라이빗 서브넷 인스턴스가 인터넷에 나가는 관문입니다. 두 가지 요금이 붙습니다.

| 항목 | 요금 |
|---|---|
| 시간당 가용 요금 | $0.045/시간/AZ |
| 데이터 처리 요금 | $0.045/GB (NAT를 통과한 모든 트래픽) |

**AZ 배치와 비용의 관계**

NAT Gateway는 특정 AZ에 생성됩니다. 다른 AZ의 인스턴스가 이 NAT Gateway를 사용하면 교차 AZ 전송 요금($0.01/GB)이 데이터 처리 요금($0.045/GB)에 추가로 붙습니다. 따라서 각 AZ에 NAT Gateway를 따로 두거나, 리소스를 NAT Gateway와 같은 AZ에 배치하는 것이 비용을 낮춥니다.

**공용 IPv4 요금까지 넣은 손익 계산** — 2024-02-01부터 AWS는 실행 중인 인스턴스에 붙은 공용 IPv4와 Elastic IP를 포함해 **모든 공용 IPv4 주소에 시간당 요금($0.005/IP/시간)**을 부과합니다. 그래서 "퍼블릭 서브넷의 인스턴스마다 공용 IP" 대신 "프라이빗 서브넷 + NAT Gateway"로 옮기는 것이 쌀 수도 있습니다. 공식 문서가 제시하는 비교식은 다음과 같습니다(합이 1보다 작으면 NAT Gateway가 더 저렴).

```
(NAT 시간 요금 + NAT 공용 IP 요금 + NAT 전송 요금) / 기존 공용 IP 비용
  NAT 시간 요금    = $0.045 × 730시간 × NAT를 둔 AZ 수
  NAT 공용 IP 요금 = $0.005 × 730시간 × NAT에 붙은 IP 수
  NAT 전송 요금    = $0.045 × 월 전송 GB
  기존 공용 IP 비용 = $0.005 × 730시간 × 공용 IPv4 주소 수
```

**S3·DynamoDB 트래픽을 Gateway Endpoint로 우회**

프라이빗 서브넷의 EC2가 S3나 DynamoDB에 접근할 때, NAT Gateway를 경유하면 처리 요금이 발생합니다. Gateway Endpoint를 사용하면 트래픽이 AWS 내부 경로로 직접 전달되어 NAT를 우회합니다.

| 구분 | NAT Gateway 경유 | Gateway Endpoint 사용 |
|---|---|---|
| NAT 처리 요금 | $0.045/GB | 없음 |
| 엔드포인트 요금 | 없음 | 없음 (Gateway Endpoint는 무료) |
| 데이터 전송 요금 | 인터넷 아웃바운드 단가 적용 | S3·DynamoDB는 같은 리전 무료 |
| 지원 서비스 | 모든 인터넷 목적지 | S3, DynamoDB만 |

> S3·DynamoDB 트래픽이 많은 프라이빗 서브넷 워크로드라면 Gateway Endpoint 추가가 비용 절감의 첫 번째 조치입니다.

> 🧠 원리: 왜 NAT Gateway는 S3로 향하는 트래픽에도 처리 요금을 부과할까요?
> NAT Gateway는 트래픽의 목적지가 S3인지 다른 인터넷 주소인지 구분하지 않고, 자신을 통과한 모든 바이트에 처리 요금을 적용합니다.
> S3 Gateway Endpoint를 추가하면 해당 트래픽은 라우팅 테이블에서 NAT가 아닌 엔드포인트로 먼저 분기되어 NAT를 거치지 않습니다.
> 결과적으로 NAT Gateway의 처리 요금 부과 대상 트래픽 자체가 줄어들어 비용이 낮아집니다.

### 3) VPC 엔드포인트 유형별 비용 {#vpc-endpoint-cost}

| 유형 | 지원 서비스 | 요금 | 용도 |
|---|---|---|---|
| **Gateway Endpoint** | S3, DynamoDB만 | **무료** | 프라이빗 서브넷 → S3/DynamoDB, NAT 우회 |
| **Interface Endpoint (PrivateLink)** | 다수의 AWS 서비스 | $0.01/GB + **엔드포인트·AZ별 시간 요금** | 그 외 AWS 서비스, SaaS, 교차 계정 서비스 |

Interface Endpoint의 시간 요금은 **엔드포인트가 프로비저닝된 AZ마다** 부과되며(서비스 연결 상태와 무관하게 과금되므로 쓰지 않는 엔드포인트는 삭제해야 합니다), 데이터 처리 요금은 리전 내 월 누적 사용량에 따라 단계적으로 인하됩니다(첫 1 PB $0.01/GB → 다음 4 PB $0.006/GB → 5 PB 초과 $0.004/GB). 인터페이스 엔드포인트를 통한 **교차 AZ 데이터 전송은 과금되지 않습니다.** 단, Gateway Endpoint로 커버 가능한 S3·DynamoDB는 Interface Endpoint를 쓸 이유가 없습니다.

> 🧠 원리: 왜 Gateway Endpoint와 Interface Endpoint는 지원 서비스 범위가 다를까요?
> Gateway Endpoint는 VPC 라우팅 테이블에 경로를 추가해 트래픽을 AWS 내부 경로로 분기하는 방식으로 동작합니다. 이 구조는 S3·DynamoDB처럼 리전 단위로 단일 엔드포인트를 제공하는 서비스에만 적용할 수 있습니다.
> Interface Endpoint(PrivateLink)는 VPC 내부에 ENI를 생성해 서비스마다 프라이빗 IP를 부여하는 방식으로, 200개 이상의 다양한 서비스에 적용 가능합니다. 대신 ENI 유지 비용과 데이터 처리 요금이 발생합니다.
> S3·DynamoDB는 두 방식 모두 적용 가능하지만 Gateway 방식이 무료이므로, 추가 비용 없이 NAT를 우회할 수 있는 첫 번째 선택지가 됩니다.

### 4) CloudFront로 오리진 전송 비용 절감 {#cloudfront-origin-cost}

CloudFront는 엣지 로케이션에 콘텐츠를 캐싱합니다. 이것이 비용에 미치는 영향은 두 가지입니다.

**오리진 아웃바운드 전송 절감**

- CloudFront가 콘텐츠를 캐싱하면 오리진(EC2, S3, ALB)까지 요청이 도달하지 않습니다.
- CloudFront ↔ AWS 오리진 간 전송 비용은 면제됩니다. 오리진이 S3이든 EC2이든 CloudFront를 경유한 전송에는 데이터 전송 요금이 부과되지 않습니다.
- 사용자에게 나가는 엣지 → 인터넷 전송 비용은 발생하지만, 동일한 트래픽을 EC2에서 직접 서빙할 때의 아웃바운드 단가보다 CloudFront 단가가 낮습니다.

**캐시 히트율(Cache Hit Ratio)이 핵심**

캐시 히트율이 높을수록 오리진 요청이 줄고, 오리진 서버 부하와 그에 따른 비용이 낮아집니다. 정적 콘텐츠(이미지, JS, CSS), 변경 빈도가 낮은 API 응답, S3 버킷 파일이 CloudFront 비용 절감에 가장 효과적입니다.

> 🧠 원리: 왜 CloudFront의 비용 절감 효과는 콘텐츠 유형에 따라 크게 달라질까요?
> 캐시에 저장된 콘텐츠는 동일한 요청이 들어올 때 오리진까지 트래픽이 전달되지 않습니다. 오리진 전송이 발생하지 않으면 오리진 아웃바운드 비용도 발생하지 않습니다.
> 정적 콘텐츠는 변경 빈도가 낮아 한 번 캐싱되면 다수의 요청을 오리진 접근 없이 처리할 수 있으므로 히트율이 높습니다. 반면 요청마다 결과가 달라지는 동적 콘텐츠는 캐시에 저장할 수 없어 매 요청이 오리진에 도달합니다.
> 이 차이가 "CloudFront는 정적 워크로드에서 비용 절감 효과가 크고 동적 워크로드에서는 제한적"이라는 결론의 근거입니다.

### 5) VPC 피어링 vs Transit Gateway — 비용 트레이드오프 {#peering-vs-tgw-cost}

두 방식 모두 VPC 간 프라이빗 연결을 제공합니다. 비용 구조가 다릅니다.

| 항목 | VPC 피어링 | Transit Gateway |
|---|---|---|
| 연결 고정 요금 | 없음 | $0.05/시간 (어태치먼트당) |
| 데이터 처리 요금 | 없음 (전송 비용만 적용) | $0.02/GB |
| 교차 AZ 전송 | AZ를 넘으면 $0.01/GB | **별도 AZ 전송 요금 없음** (TGW 처리 $0.02/GB만) |
| 관리 방식 | VPC 쌍마다 개별 설정(풀메시) | 중앙 라우터 허브 |
| 최적 규모 | VPC 수 적음 (2~5개) | VPC 수 많음 (수십 개 이상) |

> **비용 관점 결론**: VPC 수가 적고 트래픽이 적다면 VPC 피어링이 무조건 저렴합니다. VPC가 수십 개 이상이면 피어링 연결 수가 N(N-1)/2로 폭발하고 관리 비용이 뛰어 Transit Gateway의 고정 비용이 오히려 합리적입니다.

**누가 내는가도 비용 설계의 일부입니다.**

- TGW의 고정 요금은 **첨부당 시간** 단위로 붙고, 데이터 처리 요금은 **보내는 쪽 VPC 소유자**에게 과금됩니다. 그래서 **공유 TGW**(Resource Access Manager로 공유)에서는 **첨부를 만든 VPC의 소유 계정**이 그 첨부의 시간 요금을 부담합니다 — 중앙 네트워크 팀이 TGW를 두어도 요금은 각 계정으로 흩어집니다.
- **리전 간 피어링 첨부**는 과금이 두 겹입니다 — 보내는 쪽 TGW의 **데이터 처리**에 **리전 간 아웃바운드 전송**이 더해집니다. 받는 쪽 TGW에는 처리 요금이 붙지 않고 리전 간 인바운드도 과금되지 않습니다.
- VPC 피어링은 **같은 AZ 안에 머무는 전송이 무료**입니다. 그래서 피어링이든 TGW든 **AZ를 넘나드는 설계 자체**를 줄이는 것이 가장 큰 레버입니다.
- ⚠️ 피어링은 **1:1·비전이**입니다. 세 개 이상을 서로 통하게 하려면 TGW가 필요하고, 그 지점에서 비용 구조가 바뀝니다.

> 🧠 원리: 왜 VPC 수가 늘어날수록 피어링 연결 수는 VPC 수보다 훨씬 빠르게 증가할까요?
> 각 VPC 쌍은 별도의 피어링 연결이 필요합니다. VPC가 N개이면 가능한 쌍의 수는 제곱 규모로 증가하며, N이 커질수록 증가폭도 함께 커집니다.
> 연결이 늘어날수록 연결마다 양쪽 라우팅 테이블을 관리해야 하므로 운영 부담도 함께 폭증합니다.
> Transit Gateway는 각 VPC가 허브 하나와만 연결하면 되므로 N개 VPC에 연결이 N개로 유지되고, 관리 지점도 중앙 하나입니다.

### 6) Direct Connect 데이터 전송 단가 {#direct-connect-cost}

Direct Connect는 온프레미스 ↔ AWS 전용 회선입니다. 비용 구조는 포트 시간 요금과 데이터 전송 요금으로 나뉩니다.

| 항목 | Direct Connect | 인터넷 (아웃바운드) |
|---|---|---|
| 인바운드 | 무료 | 무료 |
| 아웃바운드 (AWS → 온프레미스) | $0.02/GB 수준 (US 기준) | $0.09/GB 수준 |
| 포트 시간 요금 | $0.30/시간 (1Gbps 전용) 등 | 없음 |

Direct Connect 아웃바운드 단가는 인터넷 아웃바운드 단가의 약 1/4 수준입니다. 대규모 데이터를 온프레미스로 지속적으로 전송하는 경우, 포트 시간 요금을 합산하더라도 장기적으로 비용이 낮아질 수 있습니다. 단, 초기 회선 설치 비용과 커밋 기간을 고려해야 합니다.

**총비용은 AWS 청구서 밖까지 봐야 합니다.**

- DX 비용은 **포트 시간 + 아웃바운드 전송**만이 아닙니다. **통신 사업자(ISP) 회선료**, 코로케이션의 **크로스 커넥트** 요금, **랙·상면**, 라우터 등 **장비**가 함께 듭니다. AWS 요금만 비교하면 손익분기를 잘못 잡습니다.
- ⚠️ 아웃바운드 단가와 비율은 **DX 위치와 리전마다 다릅니다.** "인터넷의 약 1/4"은 특정 지역 예시에 가까우니, 실제 판단은 **쓰는 위치의 요금표**로 합니다. AWS로 들어오는 **인바운드는 어느 위치에서나 무료**라는 점은 공통입니다.
- **SiteLink**(DX 위치끼리 AWS 백본으로 직접 연결)를 켜면 **시간 요금 + DX 전송 요금**이 추가로 붙습니다 — 지점 간 통신을 AWS 백본에 맡기는 대가입니다.
- TGW를 경유하면 그 구간의 **GB당 처리 요금**이 더해집니다(TGW 간 피어링은 한 번만).

> 🧠 원리: 왜 Direct Connect 도입이 항상 비용 절감으로 이어지지는 않을까요?
> Direct Connect는 포트 시간 요금이라는 고정 비용이 데이터 전송 여부와 무관하게 매시간 발생합니다. 전송량이 적으면 이 고정 비용이 단가 절감분을 초과해 인터넷보다 총비용이 높아질 수 있습니다.
> 전송량이 충분히 클 때만 단가 차이로 인한 절감액이 포트 시간 요금을 상쇄하고 순 절감이 발생합니다.
> 따라서 도입 전 현재 아웃바운드 전송량과 포트 시간 요금을 함께 분석해 손익분기 전송량을 초과하는지 확인해야 합니다.

---

### 7) 로드 밸런서와 공용 IP 비용 {#elb-and-public-ip-cost}

ELB 요금은 **시간당 기본 요금 + 용량 단위**입니다. 용량 단위는 ALB가 **LCU**, NLB가 **NLCU**이며, 여러 차원을 동시에 재지만 **사용량이 가장 큰 한 차원**만 과금합니다(ALB는 신규 연결·활성 연결·처리 바이트·규칙 평가, NLB는 신규 플로우·활성 플로우·처리 바이트).

- "차원을 전부 더한다"가 아니라 **최댓값 하나**만 청구되므로, 비용을 줄이려면 **내 워크로드의 지배 차원**부터 찾습니다.
- **ELB 통합**이 네트워크 비용에서 두 번 일합니다 — 호스트·경로 기반 라우팅으로 여러 앱을 하나의 ALB에 모으면 ① LB 개수만큼 붙던 시간 요금이 줄고 ② **인스턴스마다 붙던 공용 IPv4가 사라집니다**(로드 밸런서가 IP를 대신 씁니다).
- 공용 IPv4를 줄이는 다른 수단: 인스턴스의 **퍼블릭 IP 자동 할당 해제**, 관리 접속은 **EC2 Instance Connect Endpoint**로 대체, **IPv6** 전환, 퍼블릭 서브넷의 인스턴스를 **프라이빗 서브넷 + NAT**로 옮기기.
- ⚠️ 마지막 수단은 **항상 이득은 아닙니다** — NAT의 시간 요금(AZ 수만큼)과 NAT가 쓰는 공용 IP, 그리고 **GB당 처리 요금**을 합친 값이 기존 공용 IP 비용보다 작아야 의미가 있습니다. 트래픽이 많으면 NAT 처리 요금이 역전시킵니다.

> 🧠 원리: 왜 공용 IPv4 요금이 생긴 뒤 "로드 밸런서 뒤로 모으기"가 비용 설계가 됐을까요?
> 공용 IPv4는 사용 여부와 무관하게 **보유한 시간만큼** 과금되므로, 인스턴스마다 공인 IP를 달아 두면 트래픽이 없어도 대수에 비례해 요금이 쌓입니다.
> 로드 밸런서를 앞에 두면 외부에 노출되는 주소가 로드 밸런서 쪽으로 모이고 인스턴스는 사설 주소만 가져도 되므로, 같은 서비스를 유지하면서 과금 대상 주소 수가 줄어듭니다.
> 그래서 공용 IPv4 요금 도입 이후에는 "LB를 쓸지"가 가용성 문제만이 아니라 **주소 보유량을 줄이는 비용 문제**로도 다뤄집니다.

### 8) NAT 선택 — 게이트웨이 vs 인스턴스 {#nat-choice}

프라이빗 서브넷의 아웃바운드를 어떻게 낼지는 비용과 운영이 함께 걸립니다.

| 축 | NAT Gateway | **NAT 인스턴스** |
|---|---|---|
| 가용성 | AZ 안에서 이중화(관리형) | 직접 장애 조치 스크립트를 만들어야 함 |
| 대역폭 | 최대 **100 Gbps**로 자동 확장 | 인스턴스 유형에 좌우됨 |
| 관리 | AWS가 패치·운영 | 직접 패치·모니터링 |
| 크기 선택 | 불필요 | 유형·크기를 직접 골라야 함 |
| 과금 축 | 개수 × 시간 + **처리 GB** | 개수 × 시간 + 인스턴스 유형·크기 |
| 보안 그룹 | 붙일 수 없음(네트워크 ACL로 제어) | 붙일 수 있음 |

- **AWS는 NAT Gateway를 권장합니다.** NAT 인스턴스는 보안 그룹이 필요하거나 아주 작은 트래픽에서 인스턴스 요금이 더 싼 특수한 경우에만 검토합니다.
- ⚠️ 하나의 NAT Gateway는 **단일 AZ에서 동작**합니다. 그 AZ가 문제가 되면 다른 AZ의 리소스까지 아웃바운드가 끊기므로 **AZ별 1개**를 두고 **각 AZ가 자기 NAT로 나가도록** 라우팅합니다.
- NAT를 AZ별로 늘려도 **같은 AZ 트래픽의 총 처리 요금은 늘지 않습니다** — 늘어나는 것은 시간 요금이고, 줄어드는 것은 교차 AZ 전송입니다.
- **Regional NAT gateway**는 ENI가 있는 AZ로 자동 확장·축소합니다(확장에 최대 60분, 그동안은 기존 AZ에서 교차 처리). ⚠️ **Private NAT는 지원하지 않습니다.**

> 🧠 원리: 왜 NAT를 AZ마다 두는 것이 가용성뿐 아니라 비용에도 유리할까요?
> NAT가 한 AZ에만 있으면 다른 AZ의 인스턴스가 인터넷으로 나갈 때마다 트래픽이 **AZ 경계를 건너야** 하고, 그 교차 AZ 전송이 GB마다 과금됩니다.
> AZ별로 NAT를 두면 각 AZ의 트래픽이 자기 AZ 안에서 처리돼 교차 전송이 사라지고, 늘어나는 비용은 NAT 개수만큼의 시간 요금뿐입니다.
> 트래픽이 어느 정도 이상이면 교차 AZ 전송 절감이 추가 시간 요금을 넘어서므로, "AZ별 NAT"는 가용성 권고이면서 동시에 비용 권고가 됩니다.

### 9) 연결 수단의 비용 축 — VPN과 Global Accelerator {#vpn-ga-cost}

**Site-to-Site VPN**은 **연결-시간당** 과금됩니다 — 터널을 쓰지 않아도 **프로비저닝돼 있는 시간**만큼 붙습니다. 전송은 별도로 **인터넷 아웃바운드 요율**을 따르고, VPN 터널이 쓰는 **공용 IPv4**도 시간당 과금됩니다.

- ⚠️ 표준 VPN 터널은 **최대 1.25 Gbps**입니다. 더 필요하면 **Transit Gateway + 동적 라우팅의 ECMP**로 여러 터널을 묶습니다. **정적 라우팅은 ECMP가 불가**하고, **VGW는 다중 터널 ECMP를 지원하지 않아** 대용량 DX의 백업으로 VGW VPN을 쓰는 구성은 권장되지 않습니다.
- **가속 VPN**은 비용이 세 겹입니다 — VPN 연결 요금 + **Global Accelerator 2개**의 시간 요금 + **DT-Premium**.

**Global Accelerator는 절감 수단이 아닙니다.**

- 가속기마다 **고정 시간 요금**이 붙고, **비활성 상태여도 삭제하기 전까지** 계속 과금됩니다.
- 전송에는 표준 데이터 전송 요금 **위에 DT-Premium이 더해집니다**(출발 리전과 도착 엣지에 따라 다름). 가속기가 쓰는 **공용 IPv4** 요금도 별도입니다.
- 즉 GA는 **지연·가용성을 사는 기능**이고, 비용은 늘어납니다. "성능을 위해 쓴다"와 "비용을 줄인다"를 섞지 않습니다.

> 🧠 원리: 왜 VPN은 트래픽이 없어도 시간 요금이 붙을까요?
> VPN 연결은 AWS 쪽에 터널 종단점과 암호화 처리 자원이 **상시 확보**되는 구조라, 실제로 패킷이 흐르는지와 무관하게 그 자원이 점유됩니다.
> 종량제로만 과금하면 아무도 쓰지 않는 터널을 무한정 열어 두어도 비용이 0이 되어 자원이 낭비되므로, **프로비저닝된 시간**을 과금 축으로 둡니다.
> 그래서 테스트용으로 만든 VPN 연결을 지우지 않고 두는 것이 조용히 비용을 만드는 흔한 경로가 됩니다.

### 10) 요청 쪽 비용 — DNS·CDN·스로틀링 {#request-side-cost}

**Route 53**은 **호스티드 영역 월 요금 + 쿼리 요금**이 축입니다. 무료가 되는 경로를 아는 것이 절감입니다.

- **Alias 레코드가 AWS 리소스를 가리키면 그 쿼리는 무료**입니다(ELB·CloudFront·API Gateway·S3 웹사이트·VPC 엔드포인트·Global Accelerator 등). CNAME 대신 Alias를 쓰는 것만으로 쿼리 요금이 사라집니다.
- **프라이빗 호스티드 영역의 쿼리도 무료**입니다.
- ⚠️ **Resolver 엔드포인트**는 다릅니다 — **IP(ENI)마다 시간 요금**이 붙고 통과 쿼리도 과금됩니다. 하이브리드 DNS를 위해 만들어 두고 잊으면 상시 비용이 됩니다. 아웃바운드 엔드포인트를 **계정 간 공유**하고 TTL을 올려 쿼리 수를 줄입니다.

**CloudFront**는 전송을 앞으로 당겨 오리진 비용을 줄입니다.

- **AWS 오리진(S3·EC2) → CloudFront 전송은 무료**이고, 인터넷으로 나가는 전송은 월 **1 TB**까지 무료 범위가 있습니다.
- **가격 클래스**로 사용 엣지 범위를 좁히면(100/200) 단가가 낮아집니다 — 사용자가 특정 지역에 몰려 있으면 기본(All)을 고집할 이유가 없습니다.
- ⚠️ **Origin Shield**는 오리진 부하를 줄여 주지만 **요청 요금이 별도로 붙습니다.** 캐시 적중률이 이미 높으면 득보다 비용이 클 수 있습니다.

**스로틀링**은 "비용이 폭주하지 않게 막는" 장치입니다.

- **API Gateway**는 **토큰 버킷**(정상 속도 + 버스트)으로 제한하고, 한도는 **계정 수준·메서드별·클라이언트별(사용량 계획 + API 키)**로 겁니다. **계정 수준 한도는 기본 적용**되고, 초과 요청에는 **429**를 돌려줍니다.
- **WAF의 rate-based rule**은 단일 IP의 일정 시간 내 요청 수가 임계를 넘으면 차단하고, 임계 아래로 내려가면 자동으로 풉니다.
- 폭주를 막는 또 한 축은 **버퍼링**입니다 — 큐·스트림을 앞에 두면 뒤쪽 컴퓨팅이 수요에 끌려 무한정 확장되지 않습니다.

> 🧠 원리: 왜 Alias 레코드의 쿼리는 무료이고 CNAME은 과금될까요?
> CNAME은 Route 53이 외부 이름으로 한 번 더 조회를 넘기는 일반 DNS 레코드라, 질의마다 Route 53의 조회 처리가 그대로 발생합니다.
> Alias는 AWS 내부에서 대상 리소스의 주소를 직접 해석하도록 만든 전용 확장이라, AWS가 자기 리소스를 가리키는 질의를 자체 인프라 안에서 끝낼 수 있습니다.
> 그래서 AWS는 Alias 질의를 과금 대상에서 빼 두고, 결과적으로 "AWS 리소스를 가리킬 때는 Alias를 써라"가 성능 권고이자 비용 권고가 됩니다.

### 11) 네트워크 비용 검토 절차 {#network-cost-review}

네트워크 비용은 "어디서 새는지"를 먼저 찾아야 손을 댈 수 있습니다. 순서가 있습니다.

1. **어느 축인지 가른다** — Cost Explorer·CUR의 **사용 유형(usage type)**을 봅니다. `DataTransfer-Regional-Bytes` 같은 유형이 **AZ·리전 간 전송**을 가려 주고, NAT·엔드포인트·전송은 각각 다른 유형으로 잡힙니다.
2. **출처를 좁힌다** — NAT 처리 요금이 크면 **VPC Flow Logs**와 CloudWatch로 **어떤 워크로드가 NAT로 나가는지** 봅니다. 컨테이너 환경이면 네트워크 관측성 도구를 함께 씁니다.
3. **경로를 바꾼다** — S3·DynamoDB로 나가는 트래픽이라면 **게이트웨이 엔드포인트**로 돌려 NAT 처리 요금을 없앱니다. 애플리케이션과 DB가 AZ를 넘나들면 **같은 AZ로 묶어** 교차 전송을 줄입니다.
4. **유휴를 지운다** — **Compute Optimizer의 NAT Gateway 유휴 권고**와 **Trusted Advisor**(NAT의 AZ 독립성 점검)로 쓰지 않는 자원을 찾습니다.

> 🧠 원리: 왜 네트워크 비용은 "사용 유형"부터 보고 시작해야 할까요?
> 청구서의 네트워크 비용은 전송·NAT 처리·엔드포인트 시간·로드 밸런서 용량 단위처럼 **원인이 다른 항목이 한 덩어리로 보이기** 때문에, 총액만 봐서는 무엇을 고쳐야 할지 알 수 없습니다.
> 사용 유형은 그 덩어리를 과금을 일으킨 **메커니즘별로** 쪼개 주므로, "AZ를 넘어서 비싼 것"과 "NAT를 통과해서 비싼 것"을 구분할 수 있습니다.
> 메커니즘이 달라지면 해법도 달라지므로(경로 변경 vs 엔드포인트 도입 vs 자원 삭제), 분해가 선행되지 않은 최적화는 엉뚱한 곳을 고치기 쉽습니다.

---

## 📊 데이터 전송 비용 시나리오 비교 {#cost-scenarios}

| 시나리오 | 경로 | 예상 비용 |
|---|---|---|
| EC2(프라이빗) → S3 (NAT 경유) | EC2 → NAT GW → 인터넷 → S3 | NAT $0.045/GB + 아웃바운드 요금 |
| EC2(프라이빗) → S3 (Gateway Endpoint) | EC2 → Gateway Endpoint → S3 | $0 (같은 리전 무료) |
| EC2(AZ-A) → EC2(AZ-B) 프라이빗 IP | 교차 AZ | $0.01/GB (양방향) |
| EC2 → 인터넷 직접 아웃바운드 | EC2 → IGW → 인터넷 | $0.09/GB 수준 |
| EC2 → 인터넷 (CloudFront 캐싱 후) | 오리진 미도달(캐시 히트) | $0 (오리진 전송 없음) |
| VPC-A → VPC-B 교차 AZ (피어링) | VPC 피어링 | $0.01/GB |
| VPC-A → VPC-B 교차 AZ (TGW) | Transit Gateway | $0.02/GB (처리 요금만 — **TGW를 통과하는 AZ 간 트래픽에는 목적지 AZ 전송 요금이 붙지 않음**) |

---

## ✍️ 시험 포인트

- **"reduce data transfer cost" + 프라이빗 서브넷 + S3/DynamoDB** → S3 Gateway Endpoint. 무료이고 NAT 처리 요금을 완전히 없앱니다.
- **NAT Gateway 비용 최적화 두 축**: (1) AZ 배치 — NAT와 리소스를 같은 AZ에. (2) 서비스 우회 — S3·DynamoDB는 Gateway Endpoint로.
- **VPC 피어링 vs TGW 비용 선택 기준**: VPC 수가 적으면 피어링(데이터 처리 요금 없음), 많으면 TGW(관리 복잡도 상쇄).
- **CloudFront ↔ AWS 오리진 간 전송은 무료**: CloudFront 뒤에 EC2나 S3를 두면 오리진 아웃바운드 요금이 면제됩니다.
- **인바운드는 항상 무료**: 외부 → AWS 방향 전송에는 요금이 없습니다. 비용은 항상 아웃바운드·처리·교차 경계에서 발생합니다.
- **Direct Connect 아웃바운드 단가 < 인터넷 아웃바운드 단가**: 대용량 온프레미스 전송 시나리오에서는 Direct Connect가 장기적으로 저렴합니다.
- **Interface Endpoint vs Gateway Endpoint**: S3·DynamoDB는 Gateway(무료), 나머지 서비스는 Interface(유료). 시험에서 "추가 비용 없이(no additional charge)"라는 단서가 나오면 Gateway Endpoint를 고릅니다.
- **ALB 요금이 늘었는데 원인을 모른다** → **LCU 4차원 중 지배 차원**부터 확인. 전부 더하는 게 아니라 **가장 큰 한 차원**만 과금됩니다.
- **"인스턴스마다 공인 IP가 붙어 있다"** → **ELB 통합** + 퍼블릭 IP 자동 할당 해제. 관리 접속은 **EC2 Instance Connect Endpoint**, 장기적으로는 **IPv6**.
- **"NAT 인스턴스를 써도 되나"** → AWS 권장은 **NAT Gateway**. 보안 그룹이 꼭 필요하거나 트래픽이 아주 적은 특수 경우에만 NAT 인스턴스를 검토합니다.
- **NAT는 AZ별 1개** — 하나만 두면 다른 AZ 트래픽이 교차 AZ 전송 요금을 물고, 그 AZ 장애 시 전체 아웃바운드가 끊깁니다.
- **"VPN 대역폭이 부족하다"** → 터널 하나는 **최대 1.25 Gbps**. **TGW + 동적 라우팅 ECMP**로 다중 터널을 묶습니다(정적 라우팅·VGW는 불가).
- **Global Accelerator는 절감 수단이 아니다** — 가속기 **고정 시간 요금**(비활성이어도 삭제 전까지) + **DT-Premium**이 표준 전송 요금 위에 더해집니다.
- **"DNS 쿼리 요금을 줄이고 싶다"** → AWS 리소스를 가리킬 때는 **Alias**(쿼리 무료), **프라이빗 호스티드 영역 쿼리도 무료**. ⚠️ **Resolver 엔드포인트는 IP당 시간 과금**.
- **"CloudFront 비용을 더 낮추려면"** → **가격 클래스**로 엣지 범위를 좁히고 월 **1 TB** 무료 범위를 활용. ⚠️ **Origin Shield는 요청 요금이 별도**입니다.
- **"비용 폭주를 막아야 한다"** → API Gateway **토큰 버킷**(계정 수준 한도 기본 적용·초과 시 **429**) · WAF **rate-based rule** · 큐·스트림 **버퍼링**.
- **네트워크 비용은 사용 유형부터** → CUR의 `DataTransfer-Regional-Bytes` 등으로 축을 가르고 **Flow Logs**로 NAT 트래픽 출처를 좁힌 뒤 경로를 바꿉니다.
- **DX 총비용은 AWS 청구서 밖까지**: ISP 회선료·**크로스 커넥트**·랙·장비를 포함합니다. **SiteLink**는 시간 요금 + DX 전송이 추가됩니다.

---

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"프라이빗 서브넷이니까 NAT Gateway를 반드시 써야 한다."** → S3·DynamoDB는 Gateway Endpoint가 있으면 NAT 없이도 접근 가능합니다. NAT는 인터넷 트래픽 전용이고, AWS 서비스 접근에 NAT를 쓰는 것은 불필요한 비용입니다.
   *(원리: §2 — NAT는 목적지를 구분하지 않고 통과하는 모든 트래픽에 처리 요금을 부과하므로, 라우팅 테이블에서 Gateway Endpoint로 먼저 분기하면 NAT 처리 대상에서 제외된다.)*

2. **"Multi-AZ RDS를 쓰면 교차 AZ 전송 비용이 없다."** → Multi-AZ RDS의 스탠바이는 장애조치용이고 일반 쿼리는 프라이머리에만 갑니다. 그러나 애플리케이션 레이어(EC2, Lambda)가 다른 AZ에 있다면 교차 AZ 트래픽이 발생하고 $0.01/GB가 청구됩니다.
   *(원리: §1 — 장애 격리를 위해 AZ를 분리하면 AZ 경계를 넘는 트래픽 비용이 발생하며, 이는 RDS 내부 복제가 아닌 앱↔DB 구간에서도 동일하게 적용된다.)*

3. **"VPC 피어링이 Transit Gateway보다 항상 싸다."** → VPC 수가 많아지면 피어링은 N(N-1)/2개의 연결이 필요하고 운영 복잡도가 폭발합니다. 데이터 전송량이 많고 VPC가 수십 개면 Transit Gateway의 $0.02/GB 처리 요금을 내더라도 총비용이 낮아질 수 있습니다.
   *(원리: §5 — VPC 수가 증가할수록 피어링 연결 수가 제곱에 가깝게 폭증하고 관리 부담도 함께 커져 Transit Gateway 허브 방식의 고정 비용이 상대적으로 합리적이 된다.)*

4. **"CloudFront를 쓰면 오리진 서버 비용이 사라진다."** → 캐시 미스(Cache Miss) 시에는 오리진까지 요청이 전달됩니다. 비용이 줄어드는 것은 캐시 히트 비율만큼이고, 동적 콘텐츠 비율이 높으면 절감 효과가 작습니다.
   *(원리: §4 — 동적 콘텐츠는 캐시에 저장할 수 없어 매 요청이 오리진에 도달하므로, 오리진 전송 비용 절감은 정적 콘텐츠 비율에 비례한다.)*

5. **"같은 리전 트래픽은 항상 무료다."** → 같은 리전이어도 AZ가 다르고 프라이빗 IP가 아니거나, Transit Gateway를 경유하면 처리 요금이 붙습니다. "같은 AZ + 프라이빗 IP"일 때만 무료입니다.
   *(원리: §1 본문 — 비용 무료 조건은 "AZ 경계 비교차 + 프라이빗 IP" 두 조건을 동시에 충족해야 하며, 어느 하나라도 벗어나면 과금 대상이 된다.)*

6. **"Direct Connect 포트를 사면 데이터 전송이 무료다."** → Direct Connect는 포트 시간 요금과 별도로 아웃바운드 데이터 전송 요금($0.02/GB 수준)이 따로 청구됩니다. 인터넷보다 단가가 낮지만 무료는 아닙니다.
   *(원리: §6 — 포트 시간 요금은 전송량과 무관한 고정 비용이므로, 전송량이 손익분기점에 못 미치면 총비용이 인터넷보다 높아질 수 있다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 프라이빗 서브넷의 EC2 인스턴스들이 매일 수백 GB를 S3에 업로드합니다. 현재 NAT Gateway를 경유하고 있습니다. 데이터 전송 비용을 가장 효과적으로 줄이는 방법은?

<details><summary>정답 보기</summary>

**S3 Gateway Endpoint를 생성하고 해당 서브넷의 라우팅 테이블에 추가**합니다. Gateway Endpoint는 추가 요금이 없으며, S3 트래픽이 AWS 내부 경로로 직접 전달되어 NAT Gateway 처리 요금($0.045/GB)이 완전히 사라집니다. 같은 리전의 S3는 Gateway Endpoint 경유 시 데이터 전송 요금도 부과되지 않습니다.
</details>

**Q2.** 한 리전에서 VPC 10개가 서로 완전히 통신해야 합니다. 비용 트레이드오프를 어떻게 분석하나요?

<details><summary>정답 보기</summary>

VPC 피어링으로 풀메시를 구성하면 10×9/2 = 45개 연결이 필요합니다. 피어링은 데이터 처리 요금이 없지만 연결 수 관리가 복잡합니다. Transit Gateway는 어태치먼트당 $0.05/시간 + $0.02/GB 처리 요금이 붙지만 연결은 10개면 됩니다. 데이터 전송량이 크고 VPC 수가 많아질수록 Transit Gateway가 운영 및 총비용 면에서 유리합니다.
</details>

**Q3.** 글로벌 사용자에게 정적 웹사이트(이미지, CSS, JS)를 S3에서 직접 서빙 중입니다. 전송 비용과 지연을 동시에 낮추려면?

<details><summary>정답 보기</summary>

**CloudFront를 S3 앞에 배치**합니다. 엣지 로케이션에서 캐싱하면 S3 오리진까지 도달하는 요청이 대폭 줄고, CloudFront ↔ S3 오리진 간 전송 비용은 면제됩니다. 사용자 ↔ 엣지 간 전송 비용은 발생하지만, S3 직접 아웃바운드 단가보다 CloudFront 단가가 낮고 엣지 근접으로 지연도 줄어듭니다.
</details>

**Q4.** NAT Gateway가 있는 AZ-A에서 NAT Gateway를 사용 중인데, 인스턴스 대부분이 AZ-B에 있습니다. 비용 문제는 무엇이고 해결 방법은?

<details><summary>정답 보기</summary>

AZ-B 인스턴스 → AZ-A NAT Gateway 경로에 **교차 AZ 전송 요금($0.01/GB)**이 NAT 처리 요금($0.045/GB)에 추가로 붙습니다. 해결 방법은 두 가지입니다. 첫째, AZ-B에 NAT Gateway를 별도로 만들어 AZ-B 인스턴스가 같은 AZ의 NAT를 쓰게 합니다. 둘째, S3·DynamoDB 트래픽이라면 Gateway Endpoint로 우회해 NAT 경유 자체를 없앱니다.
</details>

**Q5 (원리).** 왜 VPC 피어링은 VPC 수가 적을 때 유리하고, VPC 수가 많아질수록 Transit Gateway가 관리 및 비용 면에서 합리적인 선택이 될 수 있을까요?

<details><summary>정답 보기</summary>

VPC 피어링은 완전한 연결을 위해 VPC 쌍마다 개별 연결이 필요하므로, VPC 수가 늘수록 연결 수가 제곱 규모로 증가하고 각 연결의 관리 부담도 함께 폭증합니다. Transit Gateway는 각 VPC가 허브에 연결하는 구조여서 연결 수가 VPC 수와 같게 유지되고 라우팅도 중앙에서 관리됩니다. 데이터 처리 요금이 추가되지만 대규모 환경에서는 운영 복잡도 절감이 이 비용을 상쇄할 수 있습니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. VPC 게이트웨이 엔드포인트 — https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html
2. NAT 게이트웨이 요금 — https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-pricing.html
3. Amazon VPC 요금 — https://aws.amazon.com/vpc/pricing/
4. AWS PrivateLink 요금 — https://aws.amazon.com/privatelink/pricing/
5. Amazon CloudFront 요금 — https://aws.amazon.com/cloudfront/pricing/
6. AWS Direct Connect 요금 — https://aws.amazon.com/directconnect/pricing/
7. EKS 비용 최적화 — 네트워킹("no destination cost associated with inter-AZ traffic that flows through the TGW", 피어링 동일 AZ 무료·교차 AZ 과금, 인터페이스 엔드포인트 교차 AZ 미과금) — https://docs.aws.amazon.com/eks/latest/best-practices/cost-opt-networking.html
8. EC2 인스턴스 IP 주소 지정(공용 IPv4 과금·NAT 손익 계산식) — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html
9. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
10. ELB 요금 — LCU·NLCU 차원과 **가장 큰 한 차원만 과금** — https://aws.amazon.com/elasticloadbalancing/pricing/
11. NAT 게이트웨이 vs NAT 인스턴스 비교(가용성·대역폭 100 Gbps·관리·과금 축·보안 그룹) — https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-comparison.html
12. Regional NAT gateway(자동 확장 최대 60분 · **Private NAT 미지원**) — https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateways-regional.html
13. Site-to-Site VPN 요금(**연결-시간당** · 전송은 인터넷 DTO 요율) — https://aws.amazon.com/vpn/pricing/ · https://docs.aws.amazon.com/vpn/latest/s2svpn/VPC_VPN.html
14. VPN 터널 한도와 ECMP 집계(표준 터널 **최대 1.25 Gbps** · TGW 동적 라우팅 ECMP) — https://docs.aws.amazon.com/vpn/latest/s2svpn/vpn-limits.html
15. Global Accelerator 요금(가속기당 **고정 시간 요금**·삭제 전까지 과금 · **DT-Premium**) — https://aws.amazon.com/global-accelerator/pricing/ · https://docs.aws.amazon.com/global-accelerator/latest/dg/introduction-pricing.html
16. Route 53 요금(**Alias → AWS 리소스 쿼리 무료** · **프라이빗 호스티드 영역 쿼리 무료**) — https://aws.amazon.com/route53/pricing/
17. CloudFront 요금(AWS 오리진 전송 무료 · 월 **1 TB** 무료 · **가격 클래스** · Origin Shield 요청 요금) — https://aws.amazon.com/cloudfront/pricing/pay-as-you-go/
18. Transit Gateway 요금(**첨부당 시간 요금** + GB당 처리 · 송신 VPC 소유자 과금 · 리전 간 피어링 첨부) — https://aws.amazon.com/transit-gateway/pricing/
19. 스로틀링(Well-Architected REL05-BP02 — API Gateway 토큰 버킷·큐/스트림 버퍼링) — https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/rel_mitigate_interaction_failure_throttle_requests.html · API Gateway 보안 설계 원칙 — https://docs.aws.amazon.com/whitepapers/latest/security-overview-amazon-api-gateway/security-design-principles.html

> 📝 **2026-10-24 보강 — 갭 배치 B10b(`G-4.4-01`~`11`)**: 문서에 없던 **11개 주제**를 넣었습니다. 신규 절 5개 — **§7 로드 밸런서와 공용 IP**(LCU·NLCU와 **가장 큰 한 차원만 과금** · **ELB 통합**이 LB 요금과 공용 IPv4를 동시에 줄이는 구조 · **EC2 Instance Connect Endpoint**·IPv6 · ⚠️ 퍼블릭→프라이빗+NAT 이전은 **항상 이득이 아님**), **§8 NAT 선택**(게이트웨이 vs 인스턴스 비교 축 · **AWS는 게이트웨이 권장** · ⚠️ **AZ별 1개** · Regional NAT gateway의 **Private NAT 미지원**), **§9 VPN·Global Accelerator**(VPN은 **연결-시간당**·터널 **최대 1.25 Gbps**·**ECMP 집계**·VGW 불가 · **가속 VPN의 3중 비용** · ⚠️ **GA는 절감 수단이 아님**), **§10 요청 쪽 비용**(**Alias·프라이빗 호스티드 영역 쿼리 무료** · ⚠️ **Resolver 엔드포인트는 IP당 시간 과금** · **가격 클래스**·월 1 TB·⚠️ **Origin Shield 요청 요금** · **토큰 버킷·429·rate-based rule**·버퍼링), **§11 검토 절차**(사용 유형 → **Flow Logs** → 경로 변경 → 유휴 삭제). 기존 절 보강 2곳 — §5에 **첨부당 시간 요금의 부담 주체**와 리전 간 피어링 첨부의 이중 과금, §6에 **ISP·크로스 커넥트·랙·장비**를 포함한 총비용과 **SiteLink**. ⚠️ **G-02 규율을 가장 엄하게 적용했습니다** — 이 문서는 요율이 많고 `99-gaps`의 `[의심]` 5건이 기존 요율 서술을 이미 문제 삼고 있어, 이번 배치는 **과금 축·용량 한도·무료 범위만** 쓰고 **단가를 일절 들이지 않았습니다**(VPN 시간 요금·가속기 시간 요금·Route 53 영역/쿼리/Resolver 단가·CloudFront 요청 단가와 번들 할인율·DX 위치별 DTO 예시 — 전부 가드가 금지). 기존 `$0.02/GB`·`$0.045`·`$0.01/GB` 서술은 `G-4.4-13`~`15`의 `[의심]` 소관이라 **건드리지 않았습니다**. 가드는 `test/saa_gaps_b10b_test.dart`.

> 📝 **2026-10-19 정정**: ① Transit Gateway 비용에서 **교차 AZ 전송 요금을 이중 계상**했던 칸(비교표·시나리오표)을 고쳤습니다 — TGW를 통과하는 AZ 간 트래픽에는 목적지 AZ 전송 요금이 붙지 않고 처리 요금 $0.02/GB만 적용됩니다(근거 7번). ② 인터페이스 엔드포인트 시간 요금을 "ENI별"에서 **엔드포인트·AZ별**로 고치고 처리 요금 계층과 교차 AZ 미과금을 더했습니다(근거 4·7번). ③ NAT 절감 설명에 **공용 IPv4 시간 요금($0.005/IP/시간)**과 공식 손익 계산식을 더했습니다(근거 8번).
