# ③ 학습문서 사실성 감사 샤드 — 03-docs-saa-d (t3-6~t3-9) — 2026-07

## 요약 (3~5줄)

- 4개 문서(t3-6 DynamoDB·ElastiCache / t3-7 네트워크 성능 / t3-8 하이브리드 / t3-9 데이터 분석) 전문 정독. 총 **8건**(H 1 · M 2 · L 5), 사실의심 7건.
- 최중요(H): t3-7이 "Global Accelerator를 CloudFront 앞에 붙여 고정 IP + CDN 캐싱" 조합을 가능하다고 시험 포인트로 가르침 — GA 표준 액셀러레이터 엔드포인트 유형(ALB·NLB·EC2·EIP)에 CloudFront가 없어 **불가능한 아키텍처**이며, 같은 문서 §6의 자체 엔드포인트 목록과도 모순.
- M 2건은 2024년 이후 변화 미반영: Route 53 Geoproximity의 Traffic Flow 전용 단정(2024-02부터 일반 레코드 직접 지원), Kinesis Data Streams "샤드 자동 확장 불가" 무조건 단정(온디맨드 용량 모드 누락).
- 나머지 L은 자구·각주 수준: "DX over VPN" 명칭 역전, DX "SLA 보장" 과잉 괄호, VPN 터널당 5 Gbps 주장 검증 필요, Snow 단종(Snowmobile·Snowcone) 미반영, DynamoDB 처리량 균등 분배 구형 모델.
- 핵심 시험 사실(GSI/LSI·RCU/WCU·DAX·Global Tables·캐싱 전략·라우팅 정책 7종·Alias/CNAME·ACM us-east-1·피어링 비전이·TGW·PrivateLink·게이트웨이 엔드포인트·Kinesis 4종 구분·샤드 한도·Athena/Glue/EMR/Lake Formation 역할)은 전반적으로 정확하고 SAA-C03 정답 관례와 정렬됨.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| DOC-SAA-301 | assets/content/saa/saa-t3-7.md#§7 CloudFront vs Global Accelerator 비교(표 아래 결합 문장) + 시험 포인트 "CloudFront에 고정 IP를 부여하고 싶다" 행 | "CloudFront 앞에 Global Accelerator를 붙여 고정 IP를 제공하면서 CDN 캐싱도 활용하는 구성이 가능"이라고 단정 — GA 표준 액셀러레이터의 엔드포인트 유형은 ALB·NLB·EC2 인스턴스·EIP뿐이며 **CloudFront 배포는 GA 엔드포인트로 등록 불가**(체이닝 불가능한 아키텍처). 같은 문서 §6 "엔드포인트 유형 — NLB·ALB·EC2·Elastic IP" 목록과 내부 모순. CloudFront 고정 IP 요구는 별도 기능(CloudFront Anycast Static IP, 2024-11 출시)의 영역. 시험에서 이 조합을 정답으로 고르게 유도할 수 있음. 근거: GA 개발자 가이드 엔드포인트 유형 목록에 CloudFront 부재 + CloudFront가 2024년 Anycast Static IP를 별도 출시한 사실 자체가 GA로 불가함의 방증 | H | 높 | §7 결합 문장·시험 포인트 해당 행 삭제, 또는 "둘은 체이닝이 아니라 역할 분담(정적/HTTP=CloudFront, 비-HTTP·고정 IP=GA)으로 병용"으로 재작성 | B | Y |
| DOC-SAA-302 | assets/content/saa/saa-t3-7.md#§3 라우팅 정책 7종(Geoproximity 주의 블록) + 시험 포인트 추가 포인트 + 함정 5 | "Geoproximity는 Route 53 Traffic Flow 기능에서만 사용 가능 / Traffic Flow 없이는 설정할 수 없다"를 3회 단정 — 2024-02부터 Geoproximity가 Traffic Flow 없이 일반 DNS 레코드에서 직접 지원되어 현행 사실과 불일치. 구(舊) 시험 관례·기출 문항과는 일치하므로 오답 유발 가능성은 낮으나 절대 단정("함정"으로 승격)은 현행 오류. 근거: AWS What's New 2024-02 Geoproximity 일반 레코드 지원 발표, 현행 routing-policy 공식 문서에 Traffic Flow 전제 문구 없음 | M | 중 | "과거 Traffic Flow 전용이었고 구 문항은 그 관례를 따를 수 있으나, 현재는 일반 레코드에서도 직접 설정 가능"으로 완화 | B | Y |
| DOC-SAA-303 | assets/content/saa/saa-t3-8.md#§3 Site-to-Site VPN(터널 대역폭 문단) | "Transit Gateway 연결 시 대형 대역폭 터널로 터널당 최대 5 Gbps까지 지원" — 고전·시험 관례 사실은 터널당 1.25 Gbps 고정 + TGW **ECMP로 다중 터널 집계 확장**(터널당 상향이 아님, 집계 최대 ~50 Gbps). '터널당 5 Gbps' 신기능(TGW/Cloud WAN 한정 대형 터널)의 실재·GA 여부를 확인하지 못함 — 최근 기능일 가능성이 있어 확신도 보수 적용. 표준 1.25 Gbps를 먼저 서술해 시험 정답은 보존됨. 근거: S2S VPN 공식 한도 문서의 터널당 1.25 Gbps + ECMP 집계 안내가 표준 서술 | L | 낮 | 2단 검증: 해당 기능 실재 시 발표 시점 각주 유지, 미확인이면 "ECMP 다중 터널 집계로 확장"으로 정정 | B | Y |
| DOC-SAA-304 | assets/content/saa/saa-t3-8.md#§4 DX 특성(암호화 행) + §6 조합 패턴 2 + 시험 포인트 + 함정 2 | 암호화 패턴 명칭을 "DX over VPN"으로 표기 — 설명 본문("DX 위에 VPN 터널을 얹음")과 명칭의 층위가 **반대**(문자 그대로는 'VPN 위의 DX'). AWS·업계 관례 명칭은 "VPN over Direct Connect"(Private IP VPN over DX). 시험 선택지 문구 매칭 시 경미한 혼동 소지. 아키텍처 설명 자체는 정확 | L | 높 | 전 출현부(4곳)를 "VPN over DX(DX 위 IPsec VPN)"로 자구 통일 | A | N |
| DOC-SAA-305 | assets/content/saa/saa-t3-9.md#함정 6(샤드 자동 확장) + §2 Kinesis Data Streams | "샤드 수는 자동으로 증가하지 않습니다"를 무조건 단정 — **프로비저닝 모드에만 해당**하는 사실. KDS 온디맨드 용량 모드(2021-11 출시, SAA-C03 응시 시점 범위 내)는 샤드 관리 없이 처리량을 자동 확장하며, '예측 불가 스트리밍 트래픽 + 관리 최소화' 문항의 정답 후보. 문서 전체에 온디맨드 모드 언급이 없어 해당 유형에서 오답 유발 가능. 근거: KDS capacity mode 공식 문서 — on-demand 모드는 자동 확장, provisioned 모드만 수동 샤드 관리 | M | 높 | 함정 6을 "프로비저닝 모드에서는 수동(Shard Split·UpdateShardCount), 온디맨드 모드는 자동 확장"으로 정정하고 §2에 용량 모드 2종 한 줄 추가 | B | Y |
| DOC-SAA-306 | assets/content/saa/saa-t3-9.md#§10 데이터 전송 서비스(Snow 패밀리 행) + 시험 포인트 Snow 선택 | Snowcone(수 TB)→Snowball Edge(TB~PB)→Snowmobile(EB) 3단 스펙트럼을 현행 라인업처럼 제시 — **Snowmobile·Snowcone은 2024년 단종**(현행 Snow 패밀리는 Snowball Edge 중심). 기출 관례상 선택지로 여전히 등장하므로 학습 가치는 있으나 현행 사실 각주가 없음. 근거: 2024년 AWS Snowmobile 서비스 종료 보도 및 Snow 패밀리 제품 페이지 개편(Snowcone 주문 중단) | L | 중 | 단종 각주 병기 여부 사람 결정("기출 관례용 개념 + 현재는 단종, 온라인 전송(DataSync/DX) 권장" 형태) | B | Y |
| DOC-SAA-307 | assets/content/saa/saa-t3-6.md#자가 점검 Q5 정답 | "프로비저닝 처리량도 파티션 수에 나눠 배분됩니다" — 구형 균등 분배 모델. 현행 DynamoDB는 **adaptive capacity가 핫 파티션으로 처리량을 자동·즉시 재배분**하며, 스로틀의 실제 원인은 파티션당 하드 한도(3,000 RCU/1,000 WCU) 초과. 결론(고카디널리티 PK 설계·핫 파티션 스로틀 가능)은 시험 관례와 일치해 오답 유발은 낮고 기전 설명만 구식. 근거: DynamoDB 공식 'burst/adaptive capacity' 문서 — 균등 분배 서술은 구버전 가이드의 잔재 | L | 중 | 기전을 "파티션당 하드 한도 초과 시 스로틀(adaptive capacity가 완화하지만 한도 자체는 존재)"로 재서술 | B | Y |
| DOC-SAA-308 | assets/content/saa/saa-t3-8.md#§6 VPN vs Direct Connect 비교표(대역폭·지연 행) | "일관됨 (SLA 보장)" — DX의 SLA는 **연결 가용성**(아키텍처에 따라 99.9/99.99%) 기준이며 대역폭·지연을 보장하는 SLA가 아님. '일관된 네트워크 성능'은 올바른 시험 키워드이나 괄호가 SLA 성격을 과잉 단정. 근거: AWS Direct Connect SLA 문서는 Monthly Uptime Percentage(가용성)만 규정 | L | 높 | 괄호를 "(가용성 SLA 제공)"으로 수정하거나 삭제 | A | Y |

## 비고

- t3-6의 "리전 내 3개 AZ 자동 복제", Redis 단일 스레드/IAM 인증, DAX 강력 일관성 우회, TTL 48시간, Streams 24시간 등은 공식 서술·시험 관례와 일치 — 지적 없음.
- t3-7의 Weighted 0~255, Multivalue 최대 8개, Alias 무료·Zone Apex, ACM us-east-1, NLB/ALB/GLB 구분은 정확.
- t3-8의 TGW 중복 CIDR 비전파 서술은 공식 문서 문구와 정확히 일치, DXGW의 VGW 간 트래픽 차단·게이트웨이 엔드포인트 S3/DynamoDB 전용도 정확.
- t3-9의 샤드 한도(쓰기 1 MB/s·1,000건, 읽기 2 MB/s), 보존 24h~365일, Firehose S3 경유 Redshift COPY, Athena $5/TB, Managed Flink 개명(구 Kinesis Data Analytics)은 정확.
- 샤드 내 문서 간(t3-6↔t3-7↔t3-8↔t3-9) 상호 모순은 발견되지 않음(유일한 모순은 t3-7 문서 내부의 DOC-SAA-301).
