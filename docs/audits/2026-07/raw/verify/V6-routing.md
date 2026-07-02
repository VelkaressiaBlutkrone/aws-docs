# 2단 반박 검증 — V6 Route53·CloudFront·GA — 2026-07

검증자: 독립 검증(반박 시도). 판정 3값(REFUTED=오탐/무결, CONFIRMED=지적 타당, UNCERTAIN).
각 항목 AWS 공식 문서·What's New로 확인. 반박을 적극 시도했으나 아래 4건은 모두 지적이 타당(CONFIRMED)으로 확정됨.

## 조회 출처 (URL 목록)
- https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-geoproximity.html  (Geoproximity 라우팅 — 규칙 직접 생성 서술, 지도만 Traffic Flow 한정)
- https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html  (라우팅 정책 목록 — 8종 명시, IP-based 포함)
- https://aws.amazon.com/about-aws/whats-new/2024/01/amazon-route-53-expands-geoproximity-routing/  (2024-01-10 "expands geoproximity routing" 공지)
- https://docs.aws.amazon.com/global-accelerator/latest/dg/about-endpoints.html  (GA 표준 액셀러레이터 엔드포인트 유형 — NLB·ALB·EC2·EIP)
- https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PayingForInvalidation.html  (무효화 과금 — 경로 수 기준, `/*`=1경로, 월 1,000 무료)

## 판정

| ID | 판정 | 근거(3줄 이내) |
|---|---|---|
| DOC-SAA-302 + DOC-SOA-312 | CONFIRMED | What's New 2024-01-10 "Amazon Route 53 expands geoproximity routing"가 "previously offered geoproximity routing **only within traffic flow**, but is now expanding its availability to the entire DNS service … alongside the other routing policies"라 명시 → "Traffic Flow에서만 사용 가능" 단정은 현행 오류. 공식 routing-policy-geoproximity 페이지도 규칙을 일반 레코드처럼 직접 생성하며 Traffic Flow 전제 문구 없음(지도 시각화만 Traffic Flow 한정). 지원 시작 시점=**2024-01-10**(Console·API·SDK·CLI). 시점 확정: SAA 샤드 "2024-02"는 근사 정확(1월), SOA 샤드 "2023-11"은 오기(2023-10 Traffic Flow 내 Local Zones 확장과 혼동으로 추정) — 그러나 두 샤드의 핵심 지적(=Traffic Flow 없이 설정 가능)은 모두 참. |
| DOC-SOA-313 | CONFIRMED | 문서가 인용한 routing-policy.html 현행 목록이 정확히 **8종**을 나열: simple·failover·geolocation·geoproximity·latency·**IP-based**·multivalue answer·weighted. IP-based는 2022-06 GA 이후 정식 항목. "7종" 단정은 IP-based 누락으로 과소. **샤드 간 불일치 확정: SOA(8종 지적)가 옳고, SAA 감사가 saa-t3-7 "7종"을 무결로 본 것은 오탐**(SAA 리포트 line 9의 "라우팅 정책 7종…정확" 판단 무효). |
| DOC-SOA-314 | CONFIRMED | PayingForInvalidation 공식 문서: "A path that includes the `*` wildcard **counts as one path** even if it causes CloudFront to invalidate thousands of files" + "charge … is the same regardless of the number of files … a single file (`/images/logo.jpg`) or all of the files (`/*`)". 월 1,000경로 무료. → `/*` 전체 무효화는 파일 수 무관 **1경로 과금**이므로 "잦은 전체 무효화=비용 큼" 등식은 청구 구조상 오류(캐시 적중률·오리진 부하 논지는 타당). 지적 타당. |
| DOC-SAA-301 | CONFIRMED | GA about-endpoints 공식 문서: 표준 액셀러레이터 엔드포인트는 "Network Load Balancers, Application Load Balancers, Amazon EC2 instances, or Elastic IP addresses"뿐 — **CloudFront 배포는 GA 엔드포인트로 등록 불가**. "CloudFront 앞에 GA를 붙여 고정 IP+CDN 캐싱" 구성은 체이닝 불가능한 아키텍처(문서 §6 자체 목록과도 모순). CloudFront 고정 IP는 별개 기능(Anycast Static IP, 2024-11)의 영역. 지적 타당(H 유지). |
