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
lastVerified: 2026-06-07
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

## 📖 핵심 개념

### 1) 데이터 전송 비용 구조

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

### 2) NAT Gateway 비용 구조와 절감

NAT Gateway는 프라이빗 서브넷 인스턴스가 인터넷에 나가는 관문입니다. 두 가지 요금이 붙습니다.

| 항목 | 요금 |
|---|---|
| 시간당 가용 요금 | $0.045/시간/AZ |
| 데이터 처리 요금 | $0.045/GB (NAT를 통과한 모든 트래픽) |

**AZ 배치와 비용의 관계**

NAT Gateway는 특정 AZ에 생성됩니다. 다른 AZ의 인스턴스가 이 NAT Gateway를 사용하면 교차 AZ 전송 요금($0.01/GB)이 데이터 처리 요금($0.045/GB)에 추가로 붙습니다. 따라서 각 AZ에 NAT Gateway를 따로 두거나, 리소스를 NAT Gateway와 같은 AZ에 배치하는 것이 비용을 낮춥니다.

**S3·DynamoDB 트래픽을 Gateway Endpoint로 우회**

프라이빗 서브넷의 EC2가 S3나 DynamoDB에 접근할 때, NAT Gateway를 경유하면 처리 요금이 발생합니다. Gateway Endpoint를 사용하면 트래픽이 AWS 내부 경로로 직접 전달되어 NAT를 우회합니다.

| 구분 | NAT Gateway 경유 | Gateway Endpoint 사용 |
|---|---|---|
| NAT 처리 요금 | $0.045/GB | 없음 |
| 엔드포인트 요금 | 없음 | 없음 (Gateway Endpoint는 무료) |
| 데이터 전송 요금 | 인터넷 아웃바운드 단가 적용 | S3·DynamoDB는 같은 리전 무료 |
| 지원 서비스 | 모든 인터넷 목적지 | S3, DynamoDB만 |

> S3·DynamoDB 트래픽이 많은 프라이빗 서브넷 워크로드라면 Gateway Endpoint 추가가 비용 절감의 첫 번째 조치입니다.

### 3) VPC 엔드포인트 유형별 비용

| 유형 | 지원 서비스 | 요금 | 용도 |
|---|---|---|---|
| **Gateway Endpoint** | S3, DynamoDB만 | **무료** | 프라이빗 서브넷 → S3/DynamoDB, NAT 우회 |
| **Interface Endpoint (PrivateLink)** | 200+ AWS 서비스 | $0.01/GB + 시간당 ENI 요금 | 그 외 AWS 서비스, SaaS, 교차 계정 서비스 |

Interface Endpoint의 데이터 처리 요금은 월간 누적 사용량에 따라 단계적으로 할인됩니다(1PB까지 $0.01/GB, 이후 구간별 인하). 단, Gateway Endpoint로 커버 가능한 S3·DynamoDB는 Interface Endpoint를 쓸 이유가 없습니다.

### 4) CloudFront로 오리진 전송 비용 절감

CloudFront는 엣지 로케이션에 콘텐츠를 캐싱합니다. 이것이 비용에 미치는 영향은 두 가지입니다.

**오리진 아웃바운드 전송 절감**

- CloudFront가 콘텐츠를 캐싱하면 오리진(EC2, S3, ALB)까지 요청이 도달하지 않습니다.
- CloudFront ↔ AWS 오리진 간 전송 비용은 면제됩니다. 오리진이 S3이든 EC2이든 CloudFront를 경유한 전송에는 데이터 전송 요금이 부과되지 않습니다.
- 사용자에게 나가는 엣지 → 인터넷 전송 비용은 발생하지만, 동일한 트래픽을 EC2에서 직접 서빙할 때의 아웃바운드 단가보다 CloudFront 단가가 낮습니다.

**캐시 히트율(Cache Hit Ratio)이 핵심**

캐시 히트율이 높을수록 오리진 요청이 줄고, 오리진 서버 부하와 그에 따른 비용이 낮아집니다. 정적 콘텐츠(이미지, JS, CSS), 변경 빈도가 낮은 API 응답, S3 버킷 파일이 CloudFront 비용 절감에 가장 효과적입니다.

### 5) VPC 피어링 vs Transit Gateway — 비용 트레이드오프

두 방식 모두 VPC 간 프라이빗 연결을 제공합니다. 비용 구조가 다릅니다.

| 항목 | VPC 피어링 | Transit Gateway |
|---|---|---|
| 연결 고정 요금 | 없음 | $0.05/시간 (어태치먼트당) |
| 데이터 처리 요금 | 없음 (전송 비용만 적용) | $0.02/GB |
| 교차 AZ 전송 | $0.01/GB | $0.01/GB + $0.02/GB |
| 관리 방식 | VPC 쌍마다 개별 설정(풀메시) | 중앙 라우터 허브 |
| 최적 규모 | VPC 수 적음 (2~5개) | VPC 수 많음 (수십 개 이상) |

> **비용 관점 결론**: VPC 수가 적고 트래픽이 적다면 VPC 피어링이 무조건 저렴합니다. VPC가 수십 개 이상이면 피어링 연결 수가 N(N-1)/2로 폭발하고 관리 비용이 뛰어 Transit Gateway의 고정 비용이 오히려 합리적입니다.

### 6) Direct Connect 데이터 전송 단가

Direct Connect는 온프레미스 ↔ AWS 전용 회선입니다. 비용 구조는 포트 시간 요금과 데이터 전송 요금으로 나뉩니다.

| 항목 | Direct Connect | 인터넷 (아웃바운드) |
|---|---|---|
| 인바운드 | 무료 | 무료 |
- 아웃바운드 (AWS → 온프레미스) | $0.02/GB 수준 (US 기준) | $0.09/GB 수준 |
| 포트 시간 요금 | $0.30/시간 (1Gbps 전용) 등 | 없음 |

Direct Connect 아웃바운드 단가는 인터넷 아웃바운드 단가의 약 1/4 수준입니다. 대규모 데이터를 온프레미스로 지속적으로 전송하는 경우, 포트 시간 요금을 합산하더라도 장기적으로 비용이 낮아질 수 있습니다. 단, 초기 회선 설치 비용과 커밋 기간을 고려해야 합니다.

---

## 📊 데이터 전송 비용 시나리오 비교

| 시나리오 | 경로 | 예상 비용 |
|---|---|---|
| EC2(프라이빗) → S3 (NAT 경유) | EC2 → NAT GW → 인터넷 → S3 | NAT $0.045/GB + 아웃바운드 요금 |
| EC2(프라이빗) → S3 (Gateway Endpoint) | EC2 → Gateway Endpoint → S3 | $0 (같은 리전 무료) |
| EC2(AZ-A) → EC2(AZ-B) 프라이빗 IP | 교차 AZ | $0.01/GB (양방향) |
| EC2 → 인터넷 직접 아웃바운드 | EC2 → IGW → 인터넷 | $0.09/GB 수준 |
| EC2 → 인터넷 (CloudFront 캐싱 후) | 오리진 미도달(캐시 히트) | $0 (오리진 전송 없음) |
| VPC-A → VPC-B 교차 AZ (피어링) | VPC 피어링 | $0.01/GB |
| VPC-A → VPC-B 교차 AZ (TGW) | Transit Gateway | $0.01/GB + $0.02/GB = $0.03/GB |

---

## ✍️ 시험 포인트

- **"reduce data transfer cost" + 프라이빗 서브넷 + S3/DynamoDB** → S3 Gateway Endpoint. 무료이고 NAT 처리 요금을 완전히 없앱니다.
- **NAT Gateway 비용 최적화 두 축**: (1) AZ 배치 — NAT와 리소스를 같은 AZ에. (2) 서비스 우회 — S3·DynamoDB는 Gateway Endpoint로.
- **VPC 피어링 vs TGW 비용 선택 기준**: VPC 수가 적으면 피어링(데이터 처리 요금 없음), 많으면 TGW(관리 복잡도 상쇄).
- **CloudFront ↔ AWS 오리진 간 전송은 무료**: CloudFront 뒤에 EC2나 S3를 두면 오리진 아웃바운드 요금이 면제됩니다.
- **인바운드는 항상 무료**: 외부 → AWS 방향 전송에는 요금이 없습니다. 비용은 항상 아웃바운드·처리·교차 경계에서 발생합니다.
- **Direct Connect 아웃바운드 단가 < 인터넷 아웃바운드 단가**: 대용량 온프레미스 전송 시나리오에서는 Direct Connect가 장기적으로 저렴합니다.
- **Interface Endpoint vs Gateway Endpoint**: S3·DynamoDB는 Gateway(무료), 나머지 서비스는 Interface(유료). 시험에서 "추가 비용 없이(no additional charge)"라는 단서가 나오면 Gateway Endpoint를 고릅니다.

---

## ⚠️ 흔한 함정

1. **"프라이빗 서브넷이니까 NAT Gateway를 반드시 써야 한다."** → S3·DynamoDB는 Gateway Endpoint가 있으면 NAT 없이도 접근 가능합니다. NAT는 인터넷 트래픽 전용이고, AWS 서비스 접근에 NAT를 쓰는 것은 불필요한 비용입니다.

2. **"Multi-AZ RDS를 쓰면 교차 AZ 전송 비용이 없다."** → Multi-AZ RDS의 스탠바이는 장애조치용이고 일반 쿼리는 프라이머리에만 갑니다. 그러나 애플리케이션 레이어(EC2, Lambda)가 다른 AZ에 있다면 교차 AZ 트래픽이 발생하고 $0.01/GB가 청구됩니다.

3. **"VPC 피어링이 Transit Gateway보다 항상 싸다."** → VPC 수가 많아지면 피어링은 N(N-1)/2개의 연결이 필요하고 운영 복잡도가 폭발합니다. 데이터 전송량이 많고 VPC가 수십 개면 Transit Gateway의 $0.02/GB 처리 요금을 내더라도 총비용이 낮아질 수 있습니다.

4. **"CloudFront를 쓰면 오리진 서버 비용이 사라진다."** → 캐시 미스(Cache Miss) 시에는 오리진까지 요청이 전달됩니다. 비용이 줄어드는 것은 캐시 히트 비율만큼이고, 동적 콘텐츠 비율이 높으면 절감 효과가 작습니다.

5. **"같은 리전 트래픽은 항상 무료다."** → 같은 리전이어도 AZ가 다르고 프라이빗 IP가 아니거나, Transit Gateway를 경유하면 처리 요금이 붙습니다. "같은 AZ + 프라이빗 IP"일 때만 무료입니다.

6. **"Direct Connect 포트를 사면 데이터 전송이 무료다."** → Direct Connect는 포트 시간 요금과 별도로 아웃바운드 데이터 전송 요금($0.02/GB 수준)이 따로 청구됩니다. 인터넷보다 단가가 낮지만 무료는 아닙니다.

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

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07)

1. VPC 게이트웨이 엔드포인트 — https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html
2. NAT 게이트웨이 요금 — https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-pricing.html
3. Amazon VPC 요금 — https://aws.amazon.com/vpc/pricing/
4. AWS PrivateLink 요금 — https://aws.amazon.com/privatelink/pricing/
5. Amazon CloudFront 요금 — https://aws.amazon.com/cloudfront/pricing/
6. AWS Direct Connect 요금 — https://aws.amazon.com/directconnect/pricing/
7. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
